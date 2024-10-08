# 0.4.2 (2024-10-10)

- Add TRANSCRIPTS to `AV::METADATA::FIELDS`

# 0.4.1 (2023-02-21)

- Add `BerkeleyLibrary::AV::Config.log_settings!`

# 0.4.0 (2023-01-05)

- Initial public release to RubyGems

# 0.3.0 (2022-02-01)

- Rename `Record#ucb_access?` and `Metadata#ucb_access?` to `calnet_or_ip?` for clarity.
- Remove the following methods:
  - `Record#player_link_text`
  - `Metadata#player_link_text`
  - `Metadata#player_url`
- Remove the following constants:
  - `AV::Constants::RESTRICTIONS_CALNET` 
  - `AV::Constants::RESTRICTIONS_UCB_IP`
  - `AV::Constants::RESTRICTIONS`
  - `AV::Constants::RESTRICTIONS_NONE`

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
