*** Settings ***
Library    SeleniumLibrary
Library    Collections
Library    CSVLibrary
Library    String
Library    YAMLLibrary.py

*** Variables ***
${PARAM}    ${EMPTY}  # Valeur par défaut si elle n'est pas définie
${TARGET_LANG}    ${PARAM}   # Langue passée en paramètre
${BROWSER}    Chrome
${THANK_URL}    https://mlbb--uat.sandbox.my.site.com/thank?surveyRes=
${YAML_FILE}    ../Resources/translations.yaml

*** Test Cases ***
Check Thank Page FNB    
    # Charger les traductions spécifiques à la langue
    ${datayml}=    Load YAML    ${YAML_FILE}

    # Lire les données à partir du fichier CSV
    @{datacsv}=    Read CSV File To List    ../Resources/data.csv

    # Parcourir chaque ligne du CSV avec la nouvelle syntaxe de la boucle FOR
    FOR    ${row}    IN    @{datacsv}
        
        ${lang_list}=    Get From List    ${row}    2
        # Si la langue correspond à la langue cible, ajoutez la ligne à la liste filtrée
        IF    '${lang_list}' == '${TARGET_LANG}'
                # Extraire l'URL, la division et la boutique
                ${url_suffix}=    Get From List    ${row}    0
                #${Division}=    Get From List    ${row}    1
                ${Store}=    Get From List    ${row}    1
                ${Lang}=    Get From List    ${row}    2
                ${name}=    Get From List    ${row}    3
                ${title}=    Get From List    ${row}    4
                ${salutation}=    Get From List    ${row}    5
                
                # Concaténer l'URL de remerciement avec le suffixe spécifique
                ${thk_url}=    Set Variable    ${THANK_URL}${url_suffix}&q1=Fair
                Log To Console    URL : ${thk_url}

                # Ouvrir la page et vérifier les traductions
                Check the page title    ${thk_url}    ${datayml}    ${Lang}    
                Check the body of the message    ${datayml}    ${Lang}    ${Store}    ${salutation}
                Check the name and title of the store manager    ${name}    ${title}
                Fermeture du navigateur
        END
    END

*** Keywords ***
Check the page title  
    [Arguments]    ${thk_url}    ${data}    ${trad}
    # Ouvrir le navigateur et la page
    Open Browser    ${thk_url}    ${BROWSER}
    Sleep    2s  # Attente de 2 secondes que la page se charge

    # Vérifier le titre THANK_TITLE
    ${label_text}=    Get Label Text    xpath=//div[@class='message_thankFNB']/span
    ${expect_text}=    Get Value From YAML    ${data}    ${trad}.THANK_TITLE
    Should Be Equal As Strings    ${expect_text}    ${label_text}
    Log To Console    THANK_TITLE OK
    Sleep    1s


Check the body of the message
    [Arguments]    ${data}    ${trad}   ${Store}    ${salutation}
    
    # Créer une variable qui indique si la salutation est l'une des options
    ${is_titlems_or_titlemadam}=    Evaluate    '${salutation}' == 'titlems' or '${salutation}' == 'titlemadam' or '${salutation}' == 'titlemiss'
    
    # Vérifier le texte du message TXT_FEED1
    IF    '${salutation}' == 'titlemister'
        ${label_text}=    Get Label Text    xpath=//div[@class='textFeedbackFNB']
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.TXT_FEED1_M
        Should Contain    ${label_text}    ${expect_text}
        Log To Console    TXT_FEED1_M OK

    ELSE IF    ${is_titlems_or_titlemadam}

        ${label_text}=    Get Label Text    xpath=//div[@class='textFeedbackFNB']
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.TXT_FEED1_F
        Should Contain    ${label_text}    ${expect_text}
        Log To Console    TXT_FEED1_F OK
    ELSE
        ${label_text}=    Get Label Text    xpath=//div[@class='textFeedbackFNB']
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.TXT_FEED1
        Should Contain    ${label_text}    ${expect_text}
        Log To Console    TXT_FEED1 OK
    END

    # Vérifier le texte du message TXT_FEED2
    ${label_text}=    Get Label Text    xpath=//div[@class='textFeedbackFNB']
    ${expect_text}=    Get Value From YAML    ${data}    ${trad}.TXT_FEED2
    Should Contain    ${label_text}    ${expect_text}
    Log To Console    TXT_FEED2 OK

    # Vérifier le texte du message TXT_FEED3
    IF    $trad == 'FR'
        ${label_text}=    Get Label Text    xpath=//div[@class='textFeedbackFNB']
        ${part1}=    Get Value From YAML    ${data}    ${trad}.TXT_FEED3
        ${expect_text}=    Set Variable    ${part1} Parfums et Beauté ${Store}
        Should Contain    ${label_text}    ${expect_text}
        Log To Console    TXT_FEED3 OK
    ELSE
        ${label_text}=    Get Label Text    xpath=//div[@class='textFeedbackFNB']
        ${part1}=    Get Value From YAML    ${data}    ${trad}.TXT_FEED3
        ${expect_text}=    Set Variable    ${part1} ${Store} Fragrance and Beauty
        Should Contain    ${label_text}    ${expect_text}
        Log To Console    TXT_FEED3 OK
    END

    # Vérifier le texte du message TXT_FEED3bis
    ${label_text}=    Get Label Text    xpath=//div[@class='textFeedbackFNB']
    ${expect_text}=    Get Value From YAML    ${data}    ${trad}.TXT_FEED3bis
    Should Contain    ${label_text}    ${expect_text}
    Log To Console    TXT_FEED3bis OK
    Sleep    1s


Check the name and title of the store manager
    [Arguments]       ${name}    ${title}
    # Vérifier le nom du responsable boutique NAME_RESP
    ${label_text}=    Get Label Text    xpath=//div[@class='textFeedbackFNB']
    Should Contain    ${label_text}    ${name}
    Log To Console    NAME_RESP OK

    # Vérifier le nom du responsable boutique TITLE_RESP
    ${label_text}=    Get Label Text    xpath=//div[@class='textFeedbackFNB']
    Should Contain    ${label_text}    ${title}
    Log To Console    TITLE_RESP OK
    Sleep    1s

Fermeture du navigateur
    Close Browser

Get Label Text
    [Arguments]    ${locator}
    ${element}=    Get WebElement    ${locator}
    ${text}=    Get Text    ${element}
    [Return]    ${text} 