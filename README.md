# 🪄 Terminal Linux Magique — Android + IA gratuites

Un terminal Linux complet sur **Samsung Galaxy S25 Ultra** (et tout Android 7+ en ARM64),
avec des **IA gratuites qui tournent directement sur le téléphone**, sans Internet
une fois téléchargées, sans compte et sans abonnement.

- 🐧 **Linux** : Termux + Debian complet (via `proot-distro`, **sans root**)
- 🤖 **IA locales gratuites** : Llama 3.2, Gemma 3, Qwen 2.5, Phi-4, DeepSeek R1, Mistral… (via Ollama)
- 🎨 **Thème noir** : fond noir, texte vert lime, **ce que vous tapez en blanc**
- ✨ **Commandes magiques** : `magie` (menu) et `ia "question"`

---

## 1. Installer l'APK du terminal (Termux)

Termux est l'APK de terminal Linux open source utilisée comme base.

> ⚠️ **N'installez pas Termux depuis le Play Store** (version obsolète).

1. Téléchargez l'APK depuis **F-Droid** : <https://f-droid.org/packages/com.termux/>
   ou depuis **GitHub** : <https://github.com/termux/termux-app/releases>
   (fichier `termux-app_…_arm64-v8a.apk` pour le S25 Ultra)
2. Autorisez « Installer des applis inconnues » quand Android le demande.
3. (Optionnel) Installez aussi **Termux:API** depuis la même source pour la batterie, les notifications, etc.

## 2. Installation magique (une seule commande)

Ouvrez Termux et collez :

```bash
pkg install -y git && git clone https://github.com/alexmarceauprevost812-source/apk-terminal-linux-.git && cd apk-terminal-linux- && bash install.sh
```

L'installateur :

1. met Termux à jour ;
2. installe les outils Linux (git, python, nodejs, clang, vim, htop, tmux…) ;
3. donne accès aux fichiers du téléphone (`~/storage`) ;
4. installe le moteur d'IA **Ollama** ;
5. installe **Debian** (Linux complet) ;
6. applique le **thème noir / vert lime** et installe les commandes `magie` et `ia`.

Fermez puis rouvrez Termux pour voir le thème.
Pour ne pas installer Debian : `bash install.sh --no-debian`

## 3. Télécharger une IA gratuite

```bash
magie installer-ia
```

| Pack    | Modèles                                       | Taille  |
|---------|-----------------------------------------------|---------|
| Léger ⭐ | `llama3.2:3b`                                 | ~2 Go   |
| Complet | `llama3.2:3b` + `gemma3:4b` + `qwen2.5-coder:3b` | ~7 Go   |
| Mini    | `llama3.2:1b`                                 | ~1,3 Go |

Autres IA disponibles avec `magie modeles` : `qwen2.5:3b`, `phi4-mini`,
`deepseek-r1:1.5b`, `moondream` (photos), `mistral:7b`… ou n'importe quel
modèle de <https://ollama.com/library>.

> 💡 Le S25 Ultra (12 Go de RAM) fait tourner confortablement les modèles de 1 à 4 milliards
> de paramètres, et jusqu'à 7-8 milliards plus lentement.

## 4. Utilisation

```bash
magie                         # menu interactif
ia                            # discussion avec l'IA (/bye pour quitter)
ia "Explique-moi Linux"       # réponse rapide
ia -m gemma3:4b "Bonjour"     # choisir une autre IA
cat notes.txt | ia "résume"   # l'IA lit un fichier
magie linux                   # entrer dans Debian (apt install …)
magie serveur                 # API IA sur http://127.0.0.1:11434
magie aide                    # toutes les commandes
```

`magie serveur` permet aussi d'utiliser vos IA dans des applis Android graphiques
compatibles Ollama.

## 🎨 Thème

| Élément                     | Couleur          |
|-----------------------------|------------------|
| Fond                        | noir `#000000`   |
| Texte / résultats           | vert lime `#32FF00` |
| Ce que vous tapez           | blanc            |
| Curseur                     | blanc            |

Fichiers : `config/colors.properties` (couleurs Termux, copiées dans `~/.termux/`)
et `config/theme.bashrc` (invite de commande). L'ancien thème est sauvegardé dans
`~/.termux/colors.properties.bak`.

## Pourquoi les IA ne sont pas « dans l'APK » ?

Un modèle d'IA pèse de 1 à 5 Go : l'intégrer à l'APK la rendrait énorme et figée.
Ici, les IA sont **prêtes à télécharger** en une commande depuis le terminal,
et restent ensuite **100 % hors-ligne** sur le téléphone.

## Structure

```
install.sh              installateur
bin/magie               menu magique
bin/ia                  question rapide à l'IA
config/modeles.txt      liste des IA gratuites proposées
config/colors.properties thème Termux noir / vert lime
config/theme.bashrc     invite : saisie blanche, sorties vert lime
```
