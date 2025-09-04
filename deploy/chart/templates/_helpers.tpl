{{- define "demo-app.fullname" -}}
{{- if .Chart.Name -}}{{ .Chart.Name }}{{- else -}}demo-app{{- end -}}
{{- end }}
