*** Settings ***
Library    SeleniumLibrary
Library    Collections
Library    CSVLibrary
Library    Collections
Library    String
Library    YAMLLibrary.py

*** Variables ***
${BROWSER}    Chrome
${BASE_URL}    https://mlbb--uat.sandbox.my.site.com/?surveyRes=
${YAML_FILE}    ../Resources/FNB_translations.yaml

*** Test Cases ***
Vérification de toutes les labels du VOC Survey FNB
    
    # Charger les traductions spécifiques à la langue
    ${datayml}=    Load YAML    ${YAML_FILE}

    # Lire les données à partir du fichier CSV
    @{datacsv}=    Read CSV File To List    ../Resources/survey.csv

    # Filtrer sur les données en fonction de la langue
    FOR    ${row}    IN    @{datacsv}
     # Filtrer sur les données en fonction de la langue
                ${survey_name}=    Get From List    ${row}    0
                ${url_suffix}=    Get From List    ${row}    1
                ${Store}=    Get From List    ${row}    2
                ${lang}=    Get From List    ${row}    3
                ${salutation}=    Get From List    ${row}    4


                # Concaténer l'URL de base avec le suffixe spécifique
                ${full_url}=    Set Variable    ${BASE_URL}${url_suffix}&q1=Fair
                Log To Console    URL : ${full_url}
                #Log To Console    ${full_url}

                # Ouvrir la page et vérifier les traductions
                Ouvrir le navigateur et verifier le titre    ${full_url}    ${Store}    ${datayml}    ${Lang} 
                Vérifier le toggle    ${datayml}    ${Lang}
                Vérifier la 1ere question, les boutons et indicateurs    ${datayml}    ${Lang}    ${salutation}
                Vérifier la 2eme question et les commentaires    ${datayml}    ${Lang}    
                Vérifier la 3eme question et les commentaires    ${datayml}    ${Lang}    ${salutation}
                Vérifier la 4eme question et les commentaires    ${datayml}    ${Lang} 
                Vérifier le bouton Envoyer    ${datayml}    ${Lang}
                Fermeture du navigateur        
    END



*** Keywords ***
Ouvrir le navigateur et verifier le titre
    [Arguments]    ${url}    ${Store}    ${data}    ${trad}
    
    # Ouvrir le navigateur et la page
    Open Browser    ${url}    ${BROWSER}    options=add_argument("--headless")
    Maximize Browser Window

    # Attendre que l'élément soit visible
    Wait Until Element Is Visible    xpath=//p[contains(@class, 'brand')]   timeout=20s
    Log To Console    BRAND OK

    Sleep    5s  # Attente de 5 secondes

    ${label_text}=    Get Label Text    xpath=//div[@class='messageFNB']
    #Log To Console    LABEL ${label_text}

    # Vérifier la premiere partie du titre
    ${expect_text}=    Get Value From YAML    ${data}    ${trad}.TITLE
    #Log To Console    EXPECT ${expect_text}

    Should Contain    ${label_text}    ${expect_text}
    Log To Console    TITLE OK

    # Vérifier la valeur  de la Division
    #${label_text}=    Get Label Text    xpath=//div[@class='messageFNB']
    #Should Contain    ${label_text}    ${Division}
    #Log To Console    DIVISION OK

    # Vérifier la valeur  de la boutique
    ${label_text}=    Get Label Text    xpath=//div[@class='messageFNB']
    Should Contain    ${label_text}    ${Store}
    Log To Console    STORE OK
    
Vérifier la 1ere question, les boutons et indicateurs
    [Arguments]    ${data}    ${trad}    ${salutation}

    ${label_text}=    Get Label Text    xpath=//div[@class='message2']/span
    # Créer une variable qui indique si la salutation est l'une des options
    ${is_titlems_or_titlemadam}=    Evaluate    '${salutation}' == 'titlems' or '${salutation}' == 'titlemadam' or '${salutation}' == 'titlemiss'

    # Vérifier la valeur de QUESTION_1
    IF    '${salutation}' == 'titlemister'  
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.QUESTION_M
        Should Be Equal As Strings    ${expect_text}    ${label_text}
        Log To Console    QUESTION_M OK

    ELSE IF    ${is_titlems_or_titlemadam}
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.QUESTION_F
        Should Be Equal As Strings    ${expect_text}    ${label_text}
        Log To Console    QUESTION_F OK

    ELSE
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.QUESTION_1
        Should Be Equal As Strings    ${expect_text}    ${label_text}
        Log To Console    QUESTION_1 OK
    END

    Element Should Be Visible    xpath=//div[@class='rating-scale-10FNB'] 
    Click Button    xpath=//div[@class='rating-scale-10FNB']/button[@data-value='9']
    Sleep    2s

    ${label_text}=    Get Label Text    xpath=//div[@class='rating-containerFNB']/span[@class='label-left']
    # Vérifier la valeur de LABEL_LEFT
    ${expect_text}=    Get Value From YAML    ${data}    ${trad}.LABEL_LEFT
    Should Contain    ${label_text}    ${expect_text}
    Log To Console    LABEL_LEFT OK

    ${label_text}=    Get Label Text    xpath=//div[@class='rating-containerFNB']/span[@class='label-right']
    # Vérifier la valeur de LABEL_RIGHT
    ${expect_text}=    Get Value From YAML    ${data}    ${trad}.LABEL_RIGHT
    Should Contain    ${label_text}    ${expect_text}
    Log To Console    LABEL_RIGHT OK


Vérifier la 2eme question et les commentaires
    [Arguments]    ${data}    ${trad}

    ${label_text}=    Get Label Text    xpath=//p[@class='describe']
    # Vérifier la valeur de COMMENT_HINT
    ${expect_text}=    Get Value From YAML    ${data}    ${trad}.COMMENT_HINT
    Should Be Equal As Strings    ${expect_text}    ${label_text}

    Log To Console    COMMENT_HINT OK

    # Vérifier la valeur de FEEDBACK
    ${placeholder_text}=    Get Element Attribute    xpath=//input[@class='feedback']    placeholder
    ${expect_text}=    Get Value From YAML    ${data}    ${trad}.FEEDBACK
    Should Be Equal As Strings    ${expect_text}    ${placeholder_text}
    Log To Console    FEEDBACK OK

    Sleep    2s

    # Vérifier la valeur de CHAR_COUNT
    #${label_text}=    Get Label Text    xpath=//div[@class='feedback-counter']
    #${expect_text}=    Get Value From YAML    ${data}    ${trad}.CHAR_COUNT
    #Should Be Equal As Strings    ${expect_text}    ${label_text}
    #Log To Console    CHAR_COUNT OK

Vérifier la 3eme question et les commentaires
    [Arguments]    ${data}    ${trad}    ${salutation}

    ${label_text}=    Get Label Text    xpath=//div[@class='question']/p[@class='describe']
    # Vérifier la valeur de QUESTION_2
    ${expect_text}=    Get Value From YAML    ${data}    ${trad}.QUESTION_2
    Should Be Equal As Strings    ${expect_text}    ${label_text}
    Log To Console    QUESTION_2 OK

    ${label_text}=    Get Label Text    xpath=//div[@class='question']/p[@class='saut-first']
    ${is_titlems_or_titlemadam}=    Evaluate    '${salutation}' == 'titlems' or '${salutation}' == 'titlemadam' or '${salutation}' == 'titlemiss'

     # Vérifier la valeur de RECEPTION
    # Vérifier la valeur de QUESTION_1
    IF    '${salutation}' == 'titlemister'
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.RECEPTION_M
        Should Be Equal As Strings    ${expect_text}    ${label_text}
        Log To Console    RECEPTION_M OK

    ELSE IF    ${is_titlems_or_titlemadam}
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.RECEPTION_F
        Should Be Equal As Strings    ${expect_text}    ${label_text}
        Log To Console    RECEPTION_F OK

    ELSE
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.RECEPTION
        Should Be Equal As Strings    ${expect_text}    ${label_text}
        Log To Console    RECEPTION OK
    END

    Click Button    xpath=//div[@class='question']/p[@class='saut-first']/following-sibling::div/button[@data-value='4']
    Sleep    3s

    ${label_text}=    Get Label Text    xpath=//div[@class='question']/p[@class='saut']
    ${is_titlems_or_titlemadam}=    Evaluate    '${salutation}' == 'titlems' or '${salutation}' == 'titlemadam' or '${salutation}' == 'titlemiss'

    # Vérifier la valeur de PERSONALIZED
    IF    '${salutation}' == 'titlemister'
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.PERSONALIZED_M
        Should Be Equal As Strings    ${expect_text}    ${label_text}
        Log To Console    PERSONALIZED_M OK

    ELSE IF    ${is_titlems_or_titlemadam}
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.PERSONALIZED_F
        Should Be Equal As Strings    ${expect_text}    ${label_text}
        Log To Console    PERSONALIZED_F OK

    ELSE
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.PERSONALIZED
        Should Be Equal As Strings    ${expect_text}    ${label_text}
        Log To Console    PERSONALIZED OK
    END

    Click Button    xpath=//div[@class='question']/p[@class='saut']/following-sibling::div/button[@data-value='3']
    Sleep    3s

    ${label_text}=    Get Label Text    xpath=//div[@class='question']/p[4]
    ${is_titlems_or_titlemadam}=    Evaluate    '${salutation}' == 'titlems' or '${salutation}' == 'titlemadam' or '${salutation}' == 'titlemiss'

    # Vérifier la valeur de FLUID_EXPERIENCE
    IF    '${salutation}' == 'titlemister'
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.FLUID_EXPERIENCE_M
        Should Be Equal As Strings    ${expect_text}    ${label_text}
        Log To Console    FLUID_EXPERIENCE_M OK

    ELSE IF    ${is_titlems_or_titlemadam}
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.FLUID_EXPERIENCE_F
        Should Be Equal As Strings    ${expect_text}    ${label_text}
        Log To Console    FLUID_EXPERIENCE_F OK
    
    ELSE
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.FLUID_EXPERIENCE
        Should Be Equal As Strings    ${expect_text}    ${label_text}
        Log To Console    FLUID_EXPERIENCE OK
    END

    Click Button    xpath=//div[@class='question']/p[4]/following-sibling::div/button[@data-value='5']
    Sleep    3s

    #Vérifier si Service RDV Chanel est présent
    ${status}=    Run Keyword And Return Status    Element Should Be Visible    xpath=//button[@name='7']
    ${status}=    Convert To String    ${status}

    IF    $status == 'True'
        ${label_text}=    Get Label Text    xpath=//div[@class='question']/p[5]
        # Vérifier la valeur de ADVISORS_QUESTION
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.RDV_CHANEL
        Should Be Equal As Strings    ${label_text}    ${expect_text}
        
        Click Button    xpath=//div[@class='question']/p[5]/following-sibling::div/button[@data-value='5']
        Sleep    3s

    END

    ${label_text}=    Get Label Text    xpath=//p[@class='scale-labels']/span[1]
    # Vérifier la valeur de MEDIOCRE
    ${expect_text}=    Get Value From YAML    ${data}    ${trad}.MEDIOCRE
    Should Contain    ${label_text}    ${expect_text}
    Log To Console    MEDIOCRE OK

    #Element Should Be Visible    xpath=//p[@class='scale-labels']/span
    ${label_text}=    Get Label Text    xpath=//p[@class='scale-labels']/span[2]
    # Vérifier la valeur de EXCEPTIONAL
    ${expect_text}=    Get Value From YAML    ${data}    ${trad}.EXCEPTIONAL
    Should Contain    ${label_text}    ${expect_text}
    Log To Console    EXCEPTIONAL OK


Vérifier la 4eme question et les commentaires
    [Arguments]    ${data}    ${trad}

    ${status}=    Run Keyword And Return Status    Element Should Be Visible    xpath=//button[@name='7']
    ${status}=    Convert To String    ${status}
    
    IF    $status == 'True'
        ${label_text}=    Get Label Text    xpath=//div[@class='question']/p[6]
        # Vérifier la valeur de ADVISORS_QUESTION
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.ADVISORS_QUESTION
        Should Be Equal As Strings    ${label_text}    ${expect_text}
        Log To Console    ADVISORS_QUESTION OK

        ${label_text}=    Get Label Text    xpath=//div[@class='question']/p[7]
        # Vérifier la valeur de ADVISORS_1
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.ADVISORS_1
        Should Be Equal As Strings    ${label_text}    ${expect_text}
        Log To Console    ADVISORS_1 OK

        Click Button    xpath=//div[@class='question']/p[7]/following-sibling::div/button[@data-value='1']
        Sleep    3s

        ${label_text}=    Get Label Text    xpath=//div[@class='question']/p[8]
        # Vérifier la valeur de ADVISORS_2
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.ADVISORS_2
        Should Be Equal As Strings    ${label_text}    ${expect_text}
        Log To Console    ADVISORS_2 OK

        Click Button    xpath=//div[@class='question']/p[8]/following-sibling::div/button[@data-value='2']
        Sleep    3s
    ELSE
        ${label_text}=    Get Label Text    xpath=//div[@class='question']/p[5]
        # Vérifier la valeur de ADVISORS_QUESTION
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.ADVISORS_QUESTION
        Should Be Equal As Strings    ${label_text}    ${expect_text}
        Log To Console    ADVISORS_QUESTION OK

        ${label_text}=    Get Label Text    xpath=//div[@class='question']/p[6]
        # Vérifier la valeur de ADVISORS_1
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.ADVISORS_1
        Should Be Equal As Strings    ${label_text}    ${expect_text}
        Log To Console    ADVISORS_1 OK

        Click Button    xpath=//div[@class='question']/p[6]/following-sibling::div/button[@data-value='1']
        Sleep    3s

        ${label_text}=    Get Label Text    xpath=//div[@class='question']/p[7]
        # Vérifier la valeur de ADVISORS_2
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.ADVISORS_2
        Should Be Equal As Strings    ${label_text}    ${expect_text}
        Log To Console    ADVISORS_2 OK

        Click Button    xpath=//div[@class='question']/p[7]/following-sibling::div/button[@data-value='2']
        Sleep    3s
    END

Vérifier le bouton Envoyer
    [Arguments]    ${data}    ${trad}

    Element Should Be Visible    xpath=//button[@class='submit-button']
    ${label_text}=    Get Label Text    xpath=//button[@class='submit-button']
    # Vérifier la valeur de SUBMIT
    ${expect_text}=    Get Value From YAML    ${data}    ${trad}.SUBMIT
    Should Be Equal As Strings    ${label_text}    ${expect_text}
    Log To Console    SUBMIT OK

    # Clic sur le bouton 
    #Click Button    xpath=//button[@class='submit-button']
    #Sleep    3s


Vérifier le toggle
    [Arguments]    ${data}    ${trad}

    # Verifier le bouton switch le texte de l'élément
    ${status}=    Run Keyword And Return Status    Element Should Be Visible    xpath=//label[@class='switch']
    ${status}=    Convert To String    ${status}

    IF    $status == 'True'
        ${label_text}=    Get Label Text    xpath=//span[@class='toggle-label']
        # Vérifier la valeur de SWITCH_1
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.SWITCH_1
        Should Be Equal As Strings    ${expect_text}    ${label_text}
        Log To Console    SWITCH OK

        # Cliquer et Vérifier la traduction du toggle
        Click Element    xpath=//span[@class='slider']
        Sleep    3s

        ${label_text}=    Get Label Text    xpath=//span[@class='toggle-label']
        # Vérifier la valeur de SWITCH_1B
        ${expect_text}=    Get Value From YAML    ${data}    ${trad}.SWITCH_1B
        Should Be Equal As Strings    ${label_text}    ${expect_text}
        Log To Console    SWITCH_1B OK

        # Revenir sur la traduction initiale
        Click Element    xpath=//span[@class='slider']
        Sleep    3s

    END

Vérifier le message d'erreur
    Element Should Be Visible    xpath=//p[@class='error-message-multichoice']
    Log To Console    MSG_ERROR OK


Fermeture du navigateur
    Close Browser

Get Label Text
    [Arguments]    ${locator}
    ${element}=    Get WebElement    ${locator}
    ${text}=    Get Text    ${element}
    [Return]    ${text} 