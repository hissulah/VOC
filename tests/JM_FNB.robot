*** Settings ***
Library    Process
Library    SeleniumLibrary
Library    OperatingSystem
Library    String
Library    Collections
Library    JSONLibrary
#Library    ../venv/Lib/site-packages/robot/libraries/XML.py
#Library    ../venv/Lib/site-packages/CSVLibrary/__init__.py

*** Variables ***
${RESULT_FILE}     ./Results/ResultatJMX.jtl
${DATA_FILE}    ../Resources/survey.csv


*** Test Cases ***
Exécuter JMeter et Extraire IdSurvey
    # Lancement JMeter
    #Run Process    ${JMETTER_PATH}    -n    -t    ${JMX_FILE}    -l    ${RESULT_FILE}
    File Should Exist    ${RESULT_FILE}

    ${content}=    Get File    ${RESULT_FILE}
    ${xml}=    Parse XML    ${content}
    ${samples}=    Get Elements    ${xml}    .//httpSample
    #Log    Nombre d'éléments httpSample : ${len(${samples})}

    FOR    ${sample}    IN    @{samples}
        ${responseData}=    Get Element Text    ${sample}    responseData
        ${decoded}=    Replace String    ${responseData}    &quot;    "

    END

    ${json}=    Convert String To Json    ${decoded}    
    #Log To Console    \nJSON After Parsing: ${json}    # Log après parsing pour vérifier le contenu
    
    ${composite}=    Get From Dictionary    ${json}    compositeResponse
    
    FOR    ${resp}    IN    @{composite}
        ${body}=    Get From Dictionary    ${resp}    body
        ${records}=    Get From Dictionary    ${body}    records    default=[]

        #Log To Console    \nRecords : ${records}    # Log les records avant de vérifier les types
    
        FOR    ${record}    IN    @{records}
            ${attributes}=    Get From Dictionary    ${record}    attributes
            ${type}=    Get From Dictionary    ${attributes}    type
            #Log To Console    \nRecord Type : ${type}    # Log du type de chaque record
            Run Keyword If    '${type}' == 'SurveyResponse__c'    Append Survey Data    ${record}    ${DATA_FILE}
        END
    END
    

*** Keywords ***
Append Survey Data
    [Arguments]    ${record}    ${file}

    #Trouver ID
    ${id}=    Get From Dictionary    ${record}    Id
    Log To Console    \n✅ ID SurveyResponse trouvé : ${id}

    #Trouver StoreName
    ${store_survey}=    Get From Dictionary    ${record}    StoreSurvey__r
    ${store}=    Get From Dictionary    ${store_survey}    Store__r
    ${store_name}=    Get From Dictionary    ${store}    NameForSurvey__c
    Log To Console    \n✅ Boutique trouvée: ${store_name}
    
    #Trouver la Civilité
    ${transaction}=    Get From Dictionary    ${record}    Transaction__r
    ${account}=    Get From Dictionary    ${transaction}    Account__r
    ${salutation}=    Get From Dictionary    ${account}    Salutation
    Log To Console    \n✅ Civilité trouvée: ${salutation}

    #Trouver la langue
    ${inv_lang}=    Get From Dictionary    ${record}    invitationLanguage__c
    Log To Console    \n✅ Language trouvé: ${inv_lang}

    ${data}=    Catenate    SEPARATOR=,    FNB Post Purchase	${id}    ${store_name}    ${inv_lang}    ${salutation}
    Log To Console    ${data}

    Create File    ${file}    ${data}


