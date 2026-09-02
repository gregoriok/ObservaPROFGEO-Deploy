#!/bin/bash
# ============================================================
# Cria uma Unidade Associada padrao no banco do ObservaPROFGEO
# Uso: bash scripts/setup_unidade_padrao.sh
# ============================================================

DB_CONTAINER="${DB_CONTAINER:-profgeo_db}"
DB_USER="${DB_USER:-usuario_profgeo}"
DB_NAME="${DB_NAME:-banco_profgeo}"

echo "=== Criando Unidade Associada Padrao ==="

# Verifica se o container do banco esta rodando
if ! docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER}$"; then
  echo "ERRO: Container '$DB_CONTAINER' nao esta rodando."
  echo "Execute: docker compose up -d db"
  exit 1
fi

# Verifica se ja existe alguma unidade
EXISTE=$(docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -tAc \
  "SELECT count(*) FROM unidade_associada WHERE nome_unidade = 'Coordenacao Nacional ProfGeo';" 2>/dev/null)

if [ "$EXISTE" -gt 0 ] 2>/dev/null; then
  echo "Unidade 'Coordenacao Nacional ProfGeo' ja existe. Pulando."
else
  echo "Inserindo unidade: Coordenacao Nacional ProfGeo ..."
  docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "
    INSERT INTO unidade_associada (id_unidade, nome_unidade, municipio, estado, status, is_coordenacao_nacional, data_insercao)
    VALUES (
      gen_random_uuid(),
      'Coordenacao Nacional ProfGeo',
      'Porto Alegre',
      'RS',
      true,
      true,
      NOW()
    );
  " 2>/dev/null

  if [ $? -eq 0 ]; then
    echo "Unidade criada com sucesso!"
  else
    echo "ERRO ao criar unidade."
    exit 1
  fi
fi

# Lista unidades existentes
echo ""
echo "=== Unidades cadastradas ==="
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c \
  "SELECT nome_unidade, municipio, estado, status FROM unidade_associada;" 2>/dev/null

echo ""
echo "=== Concluido ==="
