#!/usr/bin/env bash
# Setup GeoServer: workspace, datastore, and layer for profgeo
# Run once after GeoServer is up: bash scripts/setup_geoserver.sh

set -uo pipefail

GEOSERVER_URL="http://localhost:8080/geoserver"
ADMIN_USER="admin"
ADMIN_PASS="admin"
WORKSPACE="profgeo"
DATASTORE="postgis_profgeo"

DB_HOST="db"
DB_PORT="5432"
DB_NAME="banco_profgeo"
DB_USER="usuario_profgeo"
DB_PASS="senha_secreta"

CURL="curl -s -u ${ADMIN_USER}:${ADMIN_PASS}"

echo "Waiting for GeoServer to be ready..."
until [ "$(curl -s -o /dev/null -w '%{http_code}' "${GEOSERVER_URL}/rest/about/version.json" -u "${ADMIN_USER}:${ADMIN_PASS}")" = "200" ]; do
    sleep 5
    echo "  still waiting..."
done
echo "GeoServer is ready."

# 1. Create workspace
echo "Creating workspace '${WORKSPACE}'..."
$CURL -X POST "${GEOSERVER_URL}/rest/workspaces" \
    -H "Content-Type: application/json" \
    -d "{\"workspace\":{\"name\":\"${WORKSPACE}\"}}" \
    -o /dev/null -w "HTTP %{http_code}\n"

# 2. Create PostGIS datastore
echo "Creating datastore '${DATASTORE}'..."
$CURL -X POST "${GEOSERVER_URL}/rest/workspaces/${WORKSPACE}/datastores" \
    -H "Content-Type: application/json" \
    -d "{
        \"dataStore\": {
            \"name\": \"${DATASTORE}\",
            \"type\": \"PostGIS\",
            \"connectionParameters\": {
                \"entry\": [
                    {\"@key\": \"host\", \"\$\": \"${DB_HOST}\"},
                    {\"@key\": \"port\", \"\$\": \"${DB_PORT}\"},
                    {\"@key\": \"database\", \"\$\": \"${DB_NAME}\"},
                    {\"@key\": \"user\", \"\$\": \"${DB_USER}\"},
                    {\"@key\": \"passwd\", \"\$\": \"${DB_PASS}\"},
                    {\"@key\": \"dbtype\", \"\$\": \"postgis\"},
                    {\"@key\": \"schema\", \"\$\": \"public\"}
                ]
            }
        }
    }" \
    -o /dev/null -w "HTTP %{http_code}\n"

# 3. Publish escola_com_turma layer (only schools with registered classes)
echo "Publishing layer 'escola_com_turma'..."
$CURL -X POST "${GEOSERVER_URL}/rest/workspaces/${WORKSPACE}/datastores/${DATASTORE}/featuretypes" \
    -H "Content-Type: application/json" \
    -d "{
        \"featureType\": {
            \"name\": \"escola_com_turma\",
            \"nativeName\": \"escola_com_turma\",
            \"title\": \"Escolas com Turmas\",
            \"srs\": \"EPSG:4326\",
            \"enabled\": true
        }
    }" \
    -o /dev/null -w "HTTP %{http_code}\n"

echo "Done! Access GeoServer at: ${GEOSERVER_URL}/web/"
echo "Test WMS: ${GEOSERVER_URL}/${WORKSPACE}/wms?service=WMS&request=GetCapabilities"
