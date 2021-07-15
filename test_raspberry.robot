*** Settings ***
Library    SSHLibrary
Library    library_python.py
Resource    projet_keywords.robot

*** Variables ***
# Information du Raspberry PI
${ip}    78.202.120.193
${port}     22
${login}    root
${password}    ajc

# Information du git
${repo}    projet
${git}    git@github.com:nicolaspugnet/${repo}.git
${branch}    master

# Architecture du systeme
${projet_path}    /home/${login}/${repo}/
${logger_file}    ${projet_path}logger
${test_path}    ${projet_path}test/

# Chemin des fichiers de tests et fonctionnement
${test_mouvement_file}    ${test_path}test_mouvement.py
${test_signal_file}    ${test_path}test_signal.py
${test_system_file}    ${test_path}test_system.py
${test_full_system_file}    ${projet_path}Full_test/test_fonctionne.py

# Fichier en sortie des tests
${output_file_path}    output${/}sortie_test.log

# Messages des tests
${system_msg}    /dev/ttyS0 connected!
${log_error}    Parametre inconnu
${mouvement_msg}    b'Nano sent me: mouvement'
${signal_msg}    b'Nano sent me: test_signal'

*** Test Cases ***
Deploiement system
    [Documentation]    Deploiement du logiciel sur le Raspberry
    Connexion    ${ip}    ${port}    ${login}    ${password}
    Production    ${git}    ${branch}    ${login}    ${repo}    ${output_file_path}
    Terminer connexion

Test system
    Log     Test system
    [Documentation]    Verification de la connexion du Nano
    Connexion    ${ip}    ${port}   ${login}    ${password}
    ${stdout}=    Execute Command    python3 ${test_system_file}
    Terminer connexion
    Log    ${stdout}
    Presence du script    ${stdout}    ${log_error}    ${output_file_path}

Test log 1
    [Documentation]    Test unitaire : Verification du fonctionnement des logs
    Log    Tests log 1
    Connexion    ${ip}    ${port}   ${login}    ${password}
    ${stdout}=    Execute Command    ${logger_file} 1 70
    Log    ${stdout}
    Terminer connexion
    Presence du script    ${stdout}    ${log_error}    ${output_file_path}
    
Test log 2
    [Documentation]    Test unitaire : Verification du fonctionnement des logs
    Log    Tests log 2
    Connexion    ${ip}    ${port}   ${login}    ${password}
    ${stdout}=    Execute Command    ${logger_file} 2
    Log    ${stdout}
    Terminer connexion
    Presence du script    ${stdout}    ${log_error}    ${output_file_path}
    
Test log 3
    [Documentation]    Test unitaire : Verification du fonctionnement des logs
    Log    Tests log 3
    Connexion    ${ip}    ${port}   ${login}    ${password}
    ${stdout}=    Execute Command    ${logger_file} 3 102
    Log    ${stdout}
    Terminer connexion
    Presence du script    ${stdout}    ${log_error}    ${output_file_path}

Test log 4
    [Documentation]     Cas de test avec une erreur voulue
    Log    Test log erreur
    Connexion    ${ip}    ${port}   ${login}    ${password}
    ${stdout}=    Execute Command    ${logger_file} 4 50
    Log    ${stdout}
    Terminer connexion
    Presence du script    ${stdout}    ${log_error}    ${output_file_path}

Test mouvement
    [Documentation]     Test unitaire : Verification du fonctionnement de la partie capteur presence
    Log     Test mouvement
    Connexion    ${ip}    ${port}   ${login}    ${password}
    ${stdout}=    Execute Command    python3 ${test_mouvement_file}
    Terminer connexion
    Presence du script    ${stdout}    ${mouvement_msg}    ${output_file_path}

Test signal
    [Documentation]     Test unitaire : Verification du fonctionnement de la partie capteur signal
    Log     Test signal
    Connexion    ${ip}    ${port}   ${login}    ${password}
    ${stdout}=    Execute Command    python3 ${test_signal_file}
    Terminer connexion
    Presence du script    ${stdout}    ${signal_msg}    ${output_file_path}

Full Test system
    [Documentation]     Test unitaire : Verification du fonctionnement du systeme complet
    Log     Test system
    Connexion    ${ip}    ${port}   ${login}    ${password}
    ${stdout}=    Execute Command    python3 ${test_full_system_file}
    Terminer connexion
    Ecriture Dans Fichier    ${output_file_path}    Ceci est le Test Full system
    Ecriture Dans Fichier    ${output_file_path}    ${stdout}
