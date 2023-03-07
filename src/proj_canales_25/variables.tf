variable "env" {
  description = "Environment name: qa or prd"
  type        = string
  default = "qa"
}

variable "script_name_1" {
  default = "canales25_glue_job_1.py"
}

variable "glue_version" {
  description = "The version of glue to use"
  type        = string
  default     = "2.0"
}

variable "job_timeout" {
  description = "The job timeout in minutes. The default is 2880 minutes (48 hours)."
  type        = number
  default     = 2880
}
variable "max_concurrent_runs" {
  description = "The maximum number of concurrent runs allowed for a job. The default is 1"
  type        = number
  default     = 1
}

variable "max_retries" {
  description = "The maximum number of times to retry this job if it fails"
  type        = number
  default     = 0
}

variable "number_of_workers" {
  description = "The number of workers of a defined workerType that are allocated when a job runs."
  type        = number
  default     = 5
}

variable "worker_type" {
  description = "The type of predefined worker that is allocated when a job runs. Accepts a value of Standard, G.1X, or G.2X"
  type        = string
  default     = "G.1X"
}
