# Iliskisel Yapi (ER Ozeti)

## Cekirdek

- `sites` 1--N `blocks`
- `blocks` 1--N `units`
- `users` N--N `sites` (`site_memberships`)
- `units` N--N `users` (`unit_residents`)
- `units` 1--N `vehicles`

## Finans

- `units` 1--N `dues`
- `dues` N--N `payments` (`payment_allocations`)
- `units` 1--N `unit_ledger_entries`
- `units` 1--N `member_notes`

## Operasyon

- `sites` 1--N `tickets`
- `tickets` 1--N `ticket_comments`
- `sites` 1--N `announcements`
- `announcements` N--N `users` (`announcement_reads`)
- `sites` 1--N `visitors`

## Servis ve Topluluk

- `technicians` 1--N `service_requests`
- `service_requests` 1--N `service_request_photos`
- `technicians` 1--N `technician_reviews`
- `sites` 1--N `polls`
- `polls` 1--N `poll_options`
- `polls` N--N `users` (`poll_votes`)
- `sites` 1--N `facilities`
- `facilities` 1--N `facility_schedules`
- `facilities` 1--N `reservations`

## Muhasebe

- `sites` 1--N `accounts` (self-reference `parent_account_id` ile hiyerarsi)
- `accounts` 1--N `accounting_entries`
- `sites` 1--N `budgets`
- `budgets` 1--N `budget_items`
- `sites` 1--N `financial_reports`

## Kod Tablolari

- `user_roles`, `unit_relation_types`, `unit_types`
- `due_types`, `due_statuses`
- `payment_methods`, `payment_statuses`
- `ticket_categories`, `ticket_priorities`, `ticket_statuses`
- `announcement_priorities`, `visitor_statuses`
- `technician_categories`, `service_request_statuses`
- `facility_types`, `reservation_statuses`
- `account_types`, `entry_types`
- `budget_periods`, `budget_statuses`
- `report_types`, `report_periods`
- `ledger_source_types`
