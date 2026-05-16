import api from './api'

async function downloadBlob(response: any, defaultName: string) {
  const blob = response.data
  const contentDisposition = response.headers['content-disposition'] ?? ''
  const match = /filename\*=UTF-8''(.+)$/.exec(contentDisposition) || /filename="?([^";]+)"?/.exec(contentDisposition)
  const filename = match ? decodeURIComponent(match[1]) : defaultName

  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  document.body.appendChild(a)
  a.click()
  a.remove()
  URL.revokeObjectURL(url)
}

async function exportModule(path: string, defaultName: string) {
  const response = await api.get(path, { responseType: 'blob' })
  await downloadBlob(response, defaultName)
}

export async function exportDashboard(): Promise<void> {
  return exportModule('/export/dashboard', 'dashboard-report.csv')
}

export async function exportProperties(): Promise<void> {
  return exportModule('/export/properties', 'properties.csv')
}

export async function exportTaxCalculations(): Promise<void> {
  return exportModule('/export/tax-calculations', 'tax-calculations.xlsx')
}

export async function exportPayments(): Promise<void> {
  return exportModule('/export/payments', 'payments.csv')
}

export async function exportCompliance(): Promise<void> {
  return exportModule('/export/compliance', 'compliance.csv')
}

export async function exportAuditLogs(): Promise<void> {
  return exportModule('/export/audit-logs', 'audit-logs.csv')
}

export async function exportAuditEntry(id: string | number): Promise<void> {
  return exportModule(`/export/audit-logs/${id}`, `audit-log-${id}.csv`)
}

export async function exportUsers(): Promise<void> {
  return exportModule('/export/users', 'users.csv')
}

