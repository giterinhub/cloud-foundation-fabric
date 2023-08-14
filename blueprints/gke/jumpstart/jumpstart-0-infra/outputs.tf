/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "created_resources" {
  description = "IDs of the resources created, if any."
  value = merge(
    var.create_project == null ? {} : {
      project = module.project.project_id
    },
    !local.create_vpc ? {} : {
      subnet_id = values(module.vpc.0.subnet_ids)[0]
      vpc_id    = module.vpc.0.id
    },
    !var.create_registry ? {} : {
      registry = module.registry.0.image_path
    },
    !local.create_cluster ? {} : {
      cluster              = module.cluster.0.id
      node_service_account = module.cluster-service-account.0.email
    }
  )
}

output "fleet_host" {
  description = "Fleet Connect Gateway host that can be used to configure the GKE provider."
  value = join("", [
    "https://connectgateway.googleapis.com/v1/",
    "projects/${local.fleet_project.number}/",
    "locations/global/gkeMemberships/${var.cluster_name}"
  ])
}

output "get_credentials" {
  description = "Run one of these commands to get cluster credentials. Credentials via fleet allow reaching private clusters without no direct connectivity."
  value = {
    direct = join("", [
      "gcloud container clusters get-credentials ${var.cluster_name} ",
      "--project ${var.project_id} --location ${var.region}"
    ])
    fleet = join("", [
      "gcloud container fleet memberships get-credentials ${var.cluster_name}",
      " --project ${var.project_id}"
    ])
  }
}
