# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# 	https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
resource "google_cloudfunctions_function" "remove-non-org-members" {
  name                  = "RemoveNonOrganizationMembers"
  description           = "Removes all non-org members in which organization is not in the whitelist"
  runtime               = "go111"
  available_memory_mb   = 128
  source_archive_bucket = "${var.setup.gcf-bucket-name}"
  source_archive_object = "${var.setup.gcf-object-name}"
  timeout               = 60
  project               = "${var.setup.automation-project}"
  region                = "${var.setup.region}"
  entry_point           = "RemoveNonOrganizationMembers"

  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = "${var.setup.cscc-notifications-topic-prefix}-topic"
  }
}

#  Required to get and set organization policies.
resource "google_organization_iam_member" "roles-org-admin" {
  org_id = "${var.setup.organization-id}"
  role   = "roles/resourcemanager.organizationAdmin"
  member = "serviceAccount:${var.setup.automation-service-account}"
}
