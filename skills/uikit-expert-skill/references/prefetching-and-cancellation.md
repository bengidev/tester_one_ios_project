# Prefetching and Cancellation Patterns

## Goal
Reduce perceived latency while preventing wasted work.

## UITableView prefetching
Use `UITableViewDataSourcePrefetching` to start lightweight preloads for near-visible rows.

```swift
func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
  indexPaths.compactMap(modelID).forEach { id in
    tasks[id] = imageLoader.prefetch(id)
  }
}

func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
  indexPaths.compactMap(modelID).forEach { id in
    tasks[id]?.cancel()
    tasks[id] = nil
  }
}
```

## UICollectionView prefetching
Use `UICollectionViewDataSourcePrefetching` for item preloads with bounded window size.

## Rules
- Keep prefetch payload minimal (metadata/thumbnail first).
- Cancel aggressively when items move away.
- Guard final assignment by represented ID in cell configure path.

## Pitfalls
- Overly large prefetch windows causing memory/network pressure.
- Missing cancellation causing background waste.

## Checklist
- [ ] Table/collection prefetch implemented where list is image/network heavy
- [ ] Cancellation path tested under rapid scroll
- [ ] Prefetched result reused, not duplicated
