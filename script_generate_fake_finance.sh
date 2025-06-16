#!/bin/bash

# Dossier racine (à adapter à ton partage Samba)
DRIVE_ROOT="/opt/argus/opencanary_docker/share"

mkdir -p "$DRIVE_ROOT"

YEARS=$(seq 2017 2025)
MONTHS=(janvier fevrier mars avril mai juin juillet aout septembre octobre novembre decembre)
TYPES=(Charges Revenus Factures RIB Declarations Paie Assurances Emprunts Impots)

faker_fichier() {
  local dossier=$1
  local annee=$2
  local mois=$3
  local type=$4
  local i count ext

  # Nombre aléatoire de fichiers par sous-dossier (2 à 7 pour l'exemple)
  count=$(shuf -i 2-7 -n 1)
  for ((i=1;i<=count;i++)); do
    case $type in
      Factures|Charges)
        ext=pdf
        name="facture_${annee}_${mois}_${i}.pdf"
        ;;
      Revenus|Paie)
        ext=pdf
        name="bulletin_${annee}_${mois}_${i}.pdf"
        ;;
      RIB)
        ext=pdf
        name="RIB_Banque_${annee}_${i}.pdf"
        ;;
      Declarations)
        ext=csv
        name="declaration_${annee}_${mois}_${i}.csv"
        ;;
      Assurances)
        ext=pdf
        name="attestation_assurance_${annee}_${i}.pdf"
        ;;
      Emprunts)
        ext=xls
        name="tableau_amortissement_${annee}_${i}.xls"
        ;;
      Impots)
        ext=pdf
        name="avis_imposition_${annee}_${i}.pdf"
        ;;
      *)
        ext=pdf
        name="doc_${type}_${annee}_${mois}_${i}.pdf"
        ;;
    esac
    touch "${dossier}/${name}"
  done
}

for annee in $YEARS; do
  for mois in "${MONTHS[@]}"; do
    MOISPATH="$DRIVE_ROOT/$annee/$mois"
    for type in "${TYPES[@]}"; do
      SOUSPATH="$MOISPATH/$type"
      mkdir -p "$SOUSPATH"
      faker_fichier "$SOUSPATH" "$annee" "$mois" "$type"
    done
  done
done

# Ajoute quelques fichiers globaux au top-level pour la crédibilité
touch "$DRIVE_ROOT/rib_siege_principal.pdf"
touch "$DRIVE_ROOT/Listing_Comptes_Clients_2025.xlsx"
touch "$DRIVE_ROOT/rapport_audit_interne_2024.pdf"
touch "$DRIVE_ROOT/plan_investissements.xlsx"

echo "Drive factice généré dans $DRIVE_ROOT"
