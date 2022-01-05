# 0.2.3 (2022-01-05)

- `Record#bib_number` and `Metadata#bib_number` now return nil instead of raising an
  exception when the MARC field expected to contain a Millennium bib number contains
  something else.

# 0.2.2 (2022-01-03)

- Add `Record#calnet_only?` in addition to `Record#ucb_access?`

# 0.2.1 (2021-11-08)

- Add `Metadata#calnet_only?` in addition to `Metadata#ucb_access?`
- Support declaring restrictions in 998$r as well as 95640$z (Alma) or 85642$y (TIND)

# 0.2.0 (2021-10-21)

- Add Alma support
- Remove Millennium support
- Switch to [`BerkeleyLibrary/logging`](https://github.com/BerkeleyLibrary/logging)

# 0.1.0 (2021-08-05)

- Initial prerelease
- Send a custom `User-Agent` header to deal with new TIND firewall rules.
