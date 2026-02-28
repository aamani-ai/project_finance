#!/usr/bin/env bash
# Create GCS service account key for Railway deployment.
# Run this locally (requires gcloud CLI and access to infrasure-model-gpr).
# Output: gcs-key.json (add to .gitignore - never commit!)

set -e
PROJECT="infrasure-model-gpr"
SA_NAME="finance-dashboard-reader"
SA_EMAIL="${SA_NAME}@${PROJECT}.iam.gserviceaccount.com"

echo "[1/3] Creating service account ${SA_NAME}..."
gcloud iam service-accounts create "$SA_NAME" \
  --project "$PROJECT" \
  --display-name "Finance Dashboard (read-only)" \
  --description "Read-only GCS access for project_finance dashboard" 2>/dev/null || echo "  (may already exist)"

echo "[2/3] Granting Storage Object Viewer role..."
gcloud projects add-iam-policy-binding "$PROJECT" \
  --member "serviceAccount:${SA_EMAIL}" \
  --role "roles/storage.objectViewer" \
  --quiet

echo "[3/3] Creating key -> gcs-key.json..."
gcloud iam service-accounts keys create gcs-key.json \
  --iam-account "$SA_EMAIL" \
  --project "$PROJECT"

echo ""
echo "Done. Key saved to gcs-key.json"
echo "Copy the ENTIRE file contents into Railway variable: GOOGLE_APPLICATION_CREDENTIALS_JSON"
echo ""
echo "To copy to clipboard (macOS):"
echo "  cat gcs-key.json | pbcopy"
echo ""
echo "NEVER commit gcs-key.json to git!"
