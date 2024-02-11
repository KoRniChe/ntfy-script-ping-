
#!/bin/bash

# Fonction pour envoyer une notification via Curl
send_notification() {
    local message="$1"
    local tag="$2"
    # Personnalisez l'URL selon votre service de notification
    local url="http://ntfy.yourhost.com/alert"

    # Envoi de la notification via Curl avec le tag spécifié
    curl -H "ta:$tag" -d "$message" "$url"
}

# Liste des PC avec leurs adresses IP respectives
declare -A pc_list=(
    ["Serveur AIO"]="192.168.1.2"
    ["Serveur DELL"]="192.168.1.202"
    ["Serveur PVE"]="192.168.1.206"
    ["Back Office"]="192.168.1.200"
    ["PC Perso"]="192.168.1.203"
    ["Lenovo"]="192.168.1.205"
    ["webserver"]="192.168.1.207"
    ["webmail"]="192.168.1.209"
    ["cloud"]="192.168.1.211"
    ["Eggdrop"]="192.168.1.208"
    ["Guacamole"]="192.168.1.212"
    ["Kuma"]="192.168.1.213"
)

# Nombre de tentatives de ping sans réponse avant de déclarer un PC déconnecté
nombre_tentatives=5

# Initialiser l'état précédent pour chaque PC à "déconnecté"
declare -A previous_statuses
for pc in "${!pc_list[@]}"; do
    previous_statuses["$pc"]="disconnected"
done

# Boucle infinie pour surveiller l'état de connexion
while true; do
    for pc in "${!pc_list[@]}"; do
        ip="${pc_list[$pc]}"
        if ping -c $nombre_tentatives $ip &> /dev/null; then
            current_status="connected"
            tag="heavy_check_mark"
        else
            current_status="disconnected"
            tag="no_entry"
        fi

        # Vérifier si l'état a changé
        if [ "${current_status}" != "${previous_statuses[$pc]}" ]; then
            # Envoyer une notification seulement si l'état a changé
            send_notification "Le PC $pc est ${current_status}." "$tag"
            previous_statuses["$pc"]="$current_status"
        fi
    done

    sleep 60  # Attendre 60 secondes avant de vérifier à nouveau
done
