#!/bin/bash

# Define la URL del repositorio de GitHub
GIT_REPO_URL="https://github.com/EdwinMLara/UAT.git"
# Define el nombre de la carpeta del proyecto
PROJECT_NAME="UAT"

# Define la ruta del directorio del proyecto

# Obtener el nombre de usuario de Windows
# 'whoami.exe' es un comando de Windows que funciona en Git Bash y WSL
WINDOWS_USERNAME=$(whoami.exe | sed 's/.*\\//') # Extrae solo el nombre de usuario de DOMINIO\usuario

DESKTOP_PATH=""

# Detectar si estamos en WSL (Windows Subsystem for Linux)
# WSL_DISTRO_NAME es una variable de entorno común en WSL

if [ -n "$WSL_DISTRO_NAME" ] || grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    echo "Detectado: Entorno WSL."
    # En WSL, la unidad C: de Windows se monta en /mnt/c
    DESKTOP_PATH="/mnt/c/Users/$WINDOWS_USERNAME/Desktop"
elif command -v git &> /dev/null && [[ "$(git --version)" == *windows* ]]; then
    echo "Detectado: Entorno Git Bash."
    # En Git Bash, la unidad C: de Windows se mapea a /c
    DESKTOP_PATH="/c/Users/$WINDOWS_USERNAME/Desktop"
else
    echo "Advertencia: No se pudo detectar un entorno WSL o Git Bash conocido."
    echo "Intentando con una ruta genérica de Windows para Bash. Esto podría fallar."
    # Fallback genérico, podría no funcionar en todos los casos si el usuario no tiene una configuración estándar
    DESKTOP_PATH="/c/Users/$WINDOWS_USERNAME/Desktop"
fi

# Verificar si la ruta del escritorio es válida
if [ -z "$DESKTOP_PATH" ] || [ ! -d "$DESKTOP_PATH" ]; then
    echo "Error: No se pudo determinar automáticamente la ruta del Escritorio, o la ruta detectada no existe: $DESKTOP_PATH"
    echo "Por favor, especifica la ruta manualmente editando el script."
    exit 1
fi

# La ruta completa donde se clonará el repositorio
FULL_PROJECT_PATH="$DESKTOP_PATH/$PROJECT_NAME"

echo "El repositorio se clonará en: $FULL_PROJECT_PATH"


# 1) Validar si tiene Node 18

function verificar_node_18() {
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_VERSION" -eq 18 ]; then 
            return 0 # Verdadero (Node 18 está instalado)
        else
            return 1 # Falso (Node no es la versión 18) 
        fi
    else
        return 1 # Falso (Node no está instalado)
    fi
}

# 2) Si no lo tiene, instalar. Si tiene otra versión, desinstalar e instalar Node 18

if ! verificar_node_18; then
    echo "Node 18 no encontrado o es una versión diferente."
    if command -v node &> /dev/null; then
        CURRENT_NODE_VERSION=$(node -v | cut -d'v' -f2)
        echo "Desinstalando Node versión $CURRENT_NODE_VERSION..."
        echo "Por favor, desinstala manualmente la versión actual de Node si no se hace automáticamente."
    fi

    echo "Instalando Node 18..."
    if ! command -v nvm &> /dev/null; then
        echo "nvm no está instalado. Instalando nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
        # Recargar el perfil de bash para que nvm esté disponible
        source ~/.bashrc || source ~/.zshrc || source ~/.profile
    fi
    nvm install 18
    nvm use 18
    nvm alias default 18
    echo "Node 18 instalado y configurado como predeterminado."
else
    echo "Node 18 ya está instalado."
fi
# Asegurarse de que nvm use Node 18 para el script
if command -v nvm &> /dev/null; then
    nvm use 18
fi

# 3) Clonar el repositorio de Git en el Escritorio

echo "Iniciando clonación del repositorio..."

# Crea el directorio del Escritorio si no existe (raro, pero como seguridad)
mkdir -p "$DESKTOP_PATH"

if [ -d "$FULL_PROJECT_PATH" ]; then
    echo "El directorio $FULL_PROJECT_PATH ya existe. ¿Quieres eliminarlo y clonar de nuevo? (s/n)"
    read -n 1 -r REPLY
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo "Eliminando directorio existente: $FULL_PROJECT_PATH"
        rm -rf "$FULL_PROJECT_PATH"
    else
        echo "Operación de clonado cancelada. Usando el directorio existente."
    fi
fi

if [ ! -d "$FULL_PROJECT_PATH" ]; then # Si el directorio no existe o fue eliminado
    git clone "$GIT_REPO_URL" "$FULL_PROJECT_PATH"
    if [ $? -ne 0 ]; then
        echo "Error al clonar el repositorio. Saliendo."
        exit 1
    fi
else
    echo "No se clonó el repositorio porque el directorio $FULL_PROJECT_PATH ya existe y no se solicitó la eliminación."
fi

# 4) Instalar dependencias
# Ahora cambiamos al directorio clonado, que está en el Escritorio


if [ -d "$FULL_PROJECT_PATH" ]; then
    echo "Cambiando al directorio del proyecto: $FULL_PROJECT_PATH"
    cd "$FULL_PROJECT_PATH" || { echo "No se pudo cambiar al directorio del proyecto. Saliendo."; exit 1; }

    echo "Instalando dependencias (npm install)..."
    if [ -f "package-lock.json" ] || [ -f "package.json" ]; then
        npm install
        if [ $? -ne 0 ]; then
            echo "Error al instalar dependencias con npm. Intentando con yarn si está disponible."
            if command -v yarn &> /dev/null; then
                yarn install
                if [ $? -ne 0 ]; then
                    echo "Error al instalar dependencias con yarn. Saliendo."
                    exit 1
                fi
            else
                echo "Yarn no está instalado. Por favor, instala las dependencias manualmente."
                exit 1
            fi
        fi
    else
        echo "No se encontró package.json o package-lock.json. Asegúrate de que el directorio del proyecto sea correcto."
        exit 1
    fi
else
    echo "No se puede instalar dependencias, el directorio del proyecto no existe."
    exit 1
fi

# 5) Lanzar el proyecto
echo "Lanzando el proyecto..."
if [ -f "package.json" ]; then
    if grep -q '"start":' package.json; then
        npm start
    elif grep -q '"dev":' package.json; then
        npm run dev
    else
        echo "No se encontró un script 'start' o 'dev' en package.json. Lanza el proyecto manualmente."
        exit 1
    fi
else
    echo "No se encontró package.json. Lanza el proyecto manualmente."
    exit 1
fi

echo "Script finalizado."