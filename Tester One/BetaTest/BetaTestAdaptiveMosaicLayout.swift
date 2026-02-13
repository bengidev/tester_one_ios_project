import UIKit

final class BetaTestAdaptiveMosaicLayout: UICollectionViewLayout {

  // MARK: Internal

  protocol Delegate: AnyObject {
    func adaptiveMosaicLayout(
      _ layout: BetaTestAdaptiveMosaicLayout,
      preferredHeightForItemAt indexPath: IndexPath,
      fitting width: CGFloat,
    ) -> CGFloat

    func adaptiveMosaicLayout(
      _ layout: BetaTestAdaptiveMosaicLayout,
      prefersExpandedItemAt indexPath: IndexPath,
    ) -> Bool
  }

  weak var delegate: Delegate?

  var sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
  var interItemSpacing: CGFloat = 12
  var lineSpacing: CGFloat = 12
  var rowUnit: CGFloat = 10
  var minimumItemHeight: CGFloat = 120
  var singleColumnBreakpoint: CGFloat = 340
  var overlapTolerance: CGFloat = 1
  var bigItemMinimumSpan = 22
  var bigItemMaximumSpan = 60

  override var collectionViewContentSize: CGSize {
    contentSize
  }

  override func prepare() {
    super.prepare()

    guard let collectionView else { return }
    let boundsWidth = collectionView.bounds.width
    guard boundsWidth > 0 else { return }

    guard
      cachedAttributes.isEmpty
      || abs(boundsWidth - preparedBoundsWidth) > 0.5
    else { return }

    preparedBoundsWidth = boundsWidth
    cachedAttributes.removeAll()

    let itemCount = collectionView.numberOfItems(inSection: 0)
    guard itemCount > 0 else {
      contentSize = CGSize(width: boundsWidth, height: 0)
      return
    }

    let availableWidth = max(0, boundsWidth - sectionInsets.left - sectionInsets.right)
    let shouldUseSingleColumn = availableWidth <= singleColumnBreakpoint
    let columns = shouldUseSingleColumn ? 1 : 2
    let totalInterItemSpacing = interItemSpacing * CGFloat(max(0, columns - 1))
    let columnWidth = (availableWidth - totalInterItemSpacing) / CGFloat(columns)

    guard columnWidth > 0 else {
      contentSize = CGSize(width: boundsWidth, height: 0)
      return
    }

    var columnHeights = Array(repeating: sectionInsets.top, count: columns)
    var itemIndex = 0

    while itemIndex < itemCount {
      let indexPath = IndexPath(item: itemIndex, section: 0)

      if columns == 1 {
        let height = quantizedHeight(for: indexPath, width: columnWidth)
        let frame = CGRect(x: sectionInsets.left, y: columnHeights[0], width: columnWidth, height: height)
        cacheAttributes(for: indexPath, frame: frame)
        columnHeights[0] = frame.maxY + lineSpacing
        itemIndex += 1
        continue
      }

      let canExpand = delegate?.adaptiveMosaicLayout(self, prefersExpandedItemAt: indexPath) ?? false
      if !canExpand {
        let targetColumn = columnHeights[0] <= columnHeights[1] ? 0 : 1
        let frame = frameForItem(
          at: indexPath,
          column: targetColumn,
          y: columnHeights[targetColumn],
          columnWidth: columnWidth,
        )
        cacheAttributes(for: indexPath, frame: frame)
        columnHeights[targetColumn] = frame.maxY + lineSpacing
        itemIndex += 1
        continue
      }

      // Big item block with dynamic expansion when the opposite stack would overlap.
      let bigColumn = columnHeights[0] <= columnHeights[1] ? 0 : 1
      let smallColumn = 1 - bigColumn
      let bigIndexPath = indexPath
      let bigX = xOrigin(for: bigColumn, columnWidth: columnWidth)
      let bigY = columnHeights[bigColumn]

      var bigHeight = quantizedHeight(for: bigIndexPath, width: columnWidth)
      bigHeight = max(bigHeight, CGFloat(bigItemMinimumSpan) * rowUnit)
      bigHeight = min(bigHeight, CGFloat(bigItemMaximumSpan) * rowUnit)

      cacheAttributes(for: bigIndexPath, frame: CGRect(x: bigX, y: bigY, width: columnWidth, height: bigHeight))
      itemIndex += 1

      var smallStackY = columnHeights[smallColumn]

      while itemIndex < itemCount {
        let nextIndexPath = IndexPath(item: itemIndex, section: 0)
        let nextHeight = quantizedHeight(for: nextIndexPath, width: columnWidth)
        let projectedBottom = smallStackY + nextHeight
        let currentBigBottom = bigY + bigHeight

        if projectedBottom <= currentBigBottom + overlapTolerance {
          let nextFrame = CGRect(
            x: xOrigin(for: smallColumn, columnWidth: columnWidth),
            y: smallStackY,
            width: columnWidth,
            height: nextHeight,
          )
          cacheAttributes(for: nextIndexPath, frame: nextFrame)
          smallStackY = nextFrame.maxY + lineSpacing
          itemIndex += 1
          continue
        }

        if smallStackY < currentBigBottom - overlapTolerance {
          // Expand the big card to absorb overlap boundary (orange-zone concept).
          bigHeight = projectedBottom - bigY
          if let bigAttributes = cachedAttributes[bigIndexPath] {
            bigAttributes.frame.size.height = bigHeight
          }

          let nextFrame = CGRect(
            x: xOrigin(for: smallColumn, columnWidth: columnWidth),
            y: smallStackY,
            width: columnWidth,
            height: nextHeight,
          )
          cacheAttributes(for: nextIndexPath, frame: nextFrame)
          smallStackY = nextFrame.maxY + lineSpacing
          itemIndex += 1
        }

        break
      }

      columnHeights[bigColumn] = bigY + bigHeight + lineSpacing
      columnHeights[smallColumn] = smallStackY
    }

    let maxColumnHeight = columnHeights.max() ?? sectionInsets.top
    let finalHeight = max(sectionInsets.top, maxColumnHeight - lineSpacing + sectionInsets.bottom)
    contentSize = CGSize(width: boundsWidth, height: finalHeight)
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    cachedAttributes.values.filter { $0.frame.intersects(rect) }
  }

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    cachedAttributes[indexPath]
  }

  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    guard let collectionView else { return false }
    return abs(newBounds.width - collectionView.bounds.width) > 0.5
  }

  override func invalidateLayout() {
    super.invalidateLayout()
    cachedAttributes.removeAll()
  }

  // MARK: Private

  private var cachedAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
  private var contentSize = CGSize.zero
  private var preparedBoundsWidth: CGFloat = 0

  private func cacheAttributes(for indexPath: IndexPath, frame: CGRect) {
    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
    attributes.frame = frame.integral
    cachedAttributes[indexPath] = attributes
  }

  private func frameForItem(
    at indexPath: IndexPath,
    column: Int,
    y: CGFloat,
    columnWidth: CGFloat,
  ) -> CGRect {
    CGRect(
      x: xOrigin(for: column, columnWidth: columnWidth),
      y: y,
      width: columnWidth,
      height: quantizedHeight(for: indexPath, width: columnWidth),
    )
  }

  private func xOrigin(for column: Int, columnWidth: CGFloat) -> CGFloat {
    sectionInsets.left + CGFloat(column) * (columnWidth + interItemSpacing)
  }

  private func quantizedHeight(for indexPath: IndexPath, width: CGFloat) -> CGFloat {
    let preferred = delegate?.adaptiveMosaicLayout(self, preferredHeightForItemAt: indexPath, fitting: width)
      ?? minimumItemHeight
    let sanitized = max(minimumItemHeight, preferred)
    return ceil(sanitized / max(rowUnit, 1)) * max(rowUnit, 1)
  }
}
