*** Settings ***
Library    SSHLibrary

*** Keywords ***
Connexion
    [Documentation]    Processus de connexion a la machine par ardresse IP, puis nom utilisateur, et mot de passe
    [Arguments]    ${ip}    ${port}     ${login}    ${password}
    Log    Connexion a : ${ip}
    Open Connection    ${ip}    port=${port}
    Login    ${login}    ${password}

Production
    [Arguments]    ${git}    ${branch}    ${login}    ${repo}    ${output_file_path}
    [Documentation]    Processus de deploiement du logiciel du systeme de detection
    Execute command    cd
    ${stdout}=    Execute command    ls | grep '${repo}'
    Run Keyword if    '${stdout}' == '${repo}'    Run Keywords
        ...    Log    Le dossier system : existe
        ...    AND    Ecriture Dans Fichier    ${output_file_path}    Le dossier system : existe
    ...    ELSE    Run Keywords
        ...    Log    Creation du dossier system
        ...    AND    Ecriture Dans Fichier    ${output_file_path}    Creation du dossier system
        ...    AND    Execute command    git clone ${git} --quiet
        ...    AND    Execute command    cd /home/${login}/${repo}/
        ...    AND    Execute command    git pull ${git} ${branch} --quiet
        ...    AND    Execute command    git checkout ${branch} --quiet
        ...    AND    Execute command    sudo chmod 774 ${logger_file}

Terminer connexion
    [Documentation]    Processus de deconnexion a la machine
    Close Connection

Presence du script
    [Arguments]    ${stdout}    ${test_error}    ${output_file_path}
    [Documentation]    Processus de verification de la presence du script qui renvoi dans le fichier des sorties un message d'erreur ou pas
    ...    Puis d'effectuer selon les tests demandes
    Run Keyword if    "${stdout}" == "${EMPTY}"    Run Keywords
        ...    Log    Le script ne repond pas
        ...    AND    Ecriture Dans Fichier    ${output_file_path}    Le script ne repond pas
        ...    AND    Fail    ${stdout}
    ...    ELSE    Run Keywords
        ...    Run Keyword if    "${test_error}" == "/dev/ttyS0 connected!"    Verification du test    ${stdout}    ${test_error}    ${output_file_path}
        ...    AND    Run Keyword if    "${test_error}" == "Parametre inconnu"    Verification du log    ${stdout}    ${test_error}    ${output_file_path}
        ...    ELSE    Verification du test    ${stdout}    ${test_error}    ${output_file_path}

Verification du test
    [Arguments]    ${stdout}    ${log_test_msg}    ${output_file_path}
    [Documentation]    Processus de verification du port qui renvoi dans le fichier des sorties un message d'erreur ou pas
    Run Keyword if    "${stdout}" == "${log_test_msg}"    Ecriture Dans Fichier    ${output_file_path}    ${stdout}
    ...    ELSE    Run Keywords
        ...    Ecriture Dans Fichier    ${output_file_path}    ${stdout}
        ...    AND    Fail    ${stdout}

Verification du log
    [Arguments]    ${stdout}    ${log_test_msg}    ${output_file_path}
    [Documentation]    Processus de verification du log qui renvoi dans le fichier des sorties un message d'erreur ou pas
    Run Keyword if    '${stdout}' == '${log_test_msg}'    Run Keywords
    ...    Ecriture Dans Fichier    ${output_file_path}    ${stdout}
    ...    AND    Fail    ${stdout}
    ...    ELSE    Ecriture Dans Fichier    ${output_file_path}    ${stdout}
