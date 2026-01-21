# hydrus_flutter
Hydrus UI for Android in Flutter

# API Features

These are the categories I'm planning to focus on. There are a lot more, check the official [documentation](https://hydrusnetwork.github.io/hydrus/developer_api.html).

Access Management
- [x] api_version
- [ ] request_new_permissions
  - [x] api
  - [ ] ui
- [ ] session_key
- [x] verify_access_key
- [ ] get_service
- [ ] get_services
- [ ] get_service_rating_svg

Importing and Deleting Files
- [ ] add_file
- [ ] delete_files
- [ ] undelete_files
- [ ] clear_file_deletion_record
- [ ] migrate_files
- [ ] archive_files
- [ ] unarchive_files
- [ ] generate_hashes

Importing and Editing URLs
- [ ] get_url_files
- [ ] get_url_info
- [ ] add_url
- [ ] associate_url

Editing File Tags
- [ ] clean_tags
- [ ] get_favourite_tags
- [ ] get_siblings_and_parents
- [ ] search_tags
- [ ] add_tags
- [ ] set_favourite_tags

Editing File Times
- [ ] increment_file_viewtime
- [ ] set_file_viewtime
- [ ] set_time

Editing File Notes
- [ ] set_notes
- [ ] delete_notes

Searching and Fetching Files
- [ ] search_files
  - [x] basic one tag search
  - [ ] multi tag search
  - [ ] sorting
  - [ ] advanced sorting
- [ ] file_hashes
- [ ] file_metadata
- [ ] file
  - [x] api
  - [ ] ui
- [x] thumbnail
- [ ] file_path
- [ ] thumbnail_path
- [ ] local_file_storage_locations
- [ ] render

Managing File Relationships
- [ ] get_file_relationships
- [ ] get_potentials_count
- [ ] get_potential_pairs
- [ ] get_random_potentials
- [ ] remove_potentials
- [ ] set_file_relationships
- [ ] set_kings