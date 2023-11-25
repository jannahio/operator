{{/*
Expand the name of the chart.
*/}}
{{- define "jannah-helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "jannah-helm.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "jannah-helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "jannah-helm.labels" -}}
helm.sh/chart: {{ include "jannah-helm.chart" . }}
{{ include "jannah-helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "jannah-helm.frontend.labels" -}}
{{ include "jannah-helm.labels" . }}
app: {{ .Values.images.frontend.name }}
service: {{ .Values.images.frontend.name }}
{{- end }}
{{/*
Middleware labels
*/}}
{{- define "jannah-helm.middleware.labels" -}}
{{ include "jannah-helm.labels" . }}
app: {{ .Values.images.middleware.name }}
service: {{ .Values.images.middleware.name }}
{{- end }}


{{/*
Selector labels
*/}}
{{- define "jannah-helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "jannah-helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector frontend labels
*/}}
{{- define "jannah-helm.frontend.selectorLabels" -}}
{{ include "jannah-helm.selectorLabels" . }}
app: {{ .Values.images.frontend.name }}
service: {{ .Values.images.frontend.name }}
{{- end }}
{{/*
Selector middleware labels
*/}}
{{- define "jannah-helm.middleware.selectorLabels" -}}
{{ include "jannah-helm.selectorLabels" . }}
app: {{ .Values.images.middleware.name }}
service: {{ .Values.images.middleware.name }}
{{- end }}



{{/*
Create the name of the service account to use
*/}}
{{- define "jannah-helm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "jannah-helm.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
