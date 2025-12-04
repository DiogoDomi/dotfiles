#!/bin/bash

GIT_MASTER_DIR="$HOME/zMy/dotfiles/vscode/.config/Code - OSS/User"
GIT_PROFILES_DIR="$GIT_MASTER_DIR/profiles"
SYS_PROFILES_DIR="$HOME/.config/Code - OSS/User/profiles"

echo "---------------------------------------------------"
echo ""

echo "Validando existência dos diretorios..."
echo ""

if [ ! -d "$GIT_MASTER_DIR" ]; then
    exit 1
fi

echo "'$GIT_MASTER_DIR' existe!"

if [ ! -d "$GIT_PROFILES_DIR" ]; then
    exit 1
fi

echo "'$GIT_PROFILES_DIR' existe!"

if [ ! -d "$SYS_PROFILES_DIR" ]; then
    exit 1
fi

echo "'$SYS_PROFILES_DIR' existe!"
echo ""
echo "---------------------------------------------------"
echo ""

git_profiles=()
for dir in "$GIT_PROFILES_DIR"/*/; do
    name=$(basename "$dir")
    git_profiles+=("$name")
done

sys_ids=()
for dir in "$SYS_PROFILES_DIR"/*/; do
    name=$(basename "$dir")
    sys_ids+=("$name")
done

count_git=${#git_profiles[@]}
count_sys=${#sys_ids[@]}

echo "Perfis no Git: $count_git (${git_profiles[*]})"
echo "IDs no Sistema: $count_sys"
echo ""

if [ "$count_sys" -lt "$count_git" ]; then
    if [ "$count_sys" == 1 ]; then
        echo "Erro: Você tem $count_git perfis no Git, mas só criou $count_sys perfil no VS Code."
    else 
        echo "Erro: Você tem $count_git perfis no Git, mas só criou $count_sys perfis no VS Code."
    fi
    echo "Crie mais $(($count_git - $count_sys)) perfis vazios no VS Code e rode de novo."
    exit 1
fi

echo "---------------------------------------------------"
echo ""

for (( i=0; i<$count_git; i++ )); do
    profile_name="${git_profiles[$i]}"
    profile_id="${sys_ids[$i]}"
    
    target_dir="$SYS_PROFILES_DIR/$profile_id"
    source_ext="$GIT_PROFILES_DIR/$profile_name/extensions.json"
    
    echo "Conectando '$profile_name' -> ID: $profile_id"

    rm -f "$target_dir/settings.json" "$target_dir/keybindings.json" "$target_dir/extensions.json"

    if [ -f "$source_ext" ]; then
        ln -sf "$source_ext" "$target_dir/extensions.json"
    else
        echo "   Aviso: extensions.json não encontrado para $profile_name"
    fi

    ln -sf "$GIT_MASTER_DIR/settings.json" "$target_dir/settings.json"
    ln -sf "$GIT_MASTER_DIR/keybindings.json" "$target_dir/keybindings.json"
done

echo ""
echo "---------------------------------------------------"
echo ""
echo "Sucesso! Agora abra o VS Code e renomeie os perfis:"
echo ""
echo "---------------------------------------------------"
