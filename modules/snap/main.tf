terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "yandex_compute_snapshot" "onetime-snapshot" {
  depends_on     = [yandex_compute_snapshot_schedule.weekly-snapshot-schedule]
  count          = length(var.disk_ids)
  source_disk_id = var.disk_ids[count.index]
}

resource "yandex_compute_snapshot_schedule" "weekly-snapshot-schedule" {
  name = "weekly-snapshot-schedule"

  schedule_policy {
    expression = "@weekly"
  }

  snapshot_count = 1

  disk_ids = var.disk_ids
}
