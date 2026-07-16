# ============================
# Orion Git Aliases
# ============================


# ============================
# Se for no config do GIT ( eu prefiro )
# ============================

# sudo gedit ~/.gitconfig

o1 = !git branch -a && git checkout main && git branch -d marcio && git branch -a
o2 = !git pull origin main
o3 = !git checkout -b marcio
o4 = !git status -s
o5 = !git checkout main
o6 = !git merge marcio
o7 = !git push origin main


# ============================
# Se for no bash
# ============================

# sudo gedit ~/.bashrc


# o1 - Vai para main e remove branch marcio local
alias o1='git checkout main && git branch -D marcio'

# o2 - Atualiza main com GitHub
alias o2='git pull origin main'

# o3 - Cria branch marcio e muda para ela
alias o3='git checkout -b marcio'

# o5 - Volta para main
alias o5='git checkout main'

# o6 - Faz merge da branch marcio na main
alias o6='git merge marcio'

# o7 - Envia main para GitHub
alias o7='git push origin main'
