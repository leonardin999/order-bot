*** Settings ***
Documentation       Orders robots from RobotSparebin Industries Inc.
...                 Save the order HTML receipt as a PDF file.
...                 Save the screenshot of the ordered robot.
...                 Embbed the screenshot of the robot to the PDF    receipt.
...                 Creates ZIP archive of the receipts and the image.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.FileSystem
Library             DateTime
Library             RPA.Archive
Library             RPA.Dialogs


*** Variables ***
${is_Continue}          ${True}
${RECEIPT_FOLDER}       ${CURDIR}${/}receipts
${SCREENSHOT_FOLDER}    ${CURDIR}${/}screenshot
${RESULT_FOLDER}        ${CURDIR}${/}result


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    TRY
        Open the robot order website
        ${orders}=    Get orders
        FOR    ${row}    IN    @{orders}
            Close the pop up
            Fill the form    ${row}
            Preview the robot
            Submit the order
            ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
            ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
            Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}    ${row}[Order number]
            Go to order another robot
        END
        Create a ZIP file of the receipts
    FINALLY
        Log    Done.
        # Close App
    END


*** Keywords ***
Dialog as progress indicator
    [Documentation]    open the target website
    [Arguments]    ${ulr}
    Add heading    Please wait while I open a browser
    ${dialog}=    Show dialog    title=Please wait    on_top=${TRUE}
    Open Chrome Browser    ${ulr}    maximized=${True}
    Close dialog    ${dialog}

Open the robot order website
    [Documentation]    open the target website and click the pop up
    Dialog as progress indicator    https://robotsparebinindustries.com/#/robot-order
    # Click Button    OK

Confirmation dialog
    Add icon    Warning
    Add heading    Delete user ${username}?
    Add submit buttons    buttons=No,Yes    default=Yes
    ${result}=    Run dialog
    IF    $result.submit == "Yes"    Delete user    ${username}

Get orders
    [Documentation]    downlad the input file and read it as datatable
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}    target_file=input/orders.csv
    ${table}=    Read table from CSV    input/orders.csv
    RETURN    ${table}

Close the pop up
    [Documentation]    close the pop up when it appear!
    Wait Until Element Is Visible    css:button.btn.btn-dark
    Click Button    OK

Preview the robot
    [Documentation]    review the image of ordered robot
    Click Element    css: button#preview
    Wait Until Page Contains Element    css:div#robot-preview-image

Submit the order
    [Documentation]    confirm to order the request robot
    ${is_Continue}=    Set Variable    ${True}
    WHILE    ${is_Continue} == ${True}
        Click Element    css:button#order
        ${is_Continue}=    Is Element Visible    css:div.alert.alert-danger
    END
    Wait Until Page Contains Element    css:button#order-another

Fill the form
    [Documentation]    complete the form with each row of data of given input
    [Arguments]    ${data}
    Select From List By Value    css:#head.custom-select    ${data}[Head]
    Click Element    css:#id-body-${data}[Body]
    Input Text    alias:Input-legs    ${data}[Legs]
    Input Text    css:#address    ${data}[Address]
    Click Button    css:#preview

Store the receipt as a PDF file
    [Documentation]    using the HTML to PDF Method to stored the designed robot information
    [Arguments]    ${index}
    ${pdf}=    Set Variable    ${RECEIPT_FOLDER}${/}order_${index}.pdf
    Check for directory    ${RECEIPT_FOLDER}
    Wait Until Element Is Visible    css:div#receipt
    ${recept_content}=    Get Element Attribute    css:div#receipt    outerHTML
    Html To Pdf    ${recept_content}    ${pdf}
    RETURN    ${pdf}

Take a screenshot of the robot
    [Documentation]    using the Scree to stored the designed robot information
    [Arguments]    ${index}
    ${screen}=    Set Variable    ${SCREENSHOT_FOLDER}${/}order_${index}.png
    Check for directory    ${SCREENSHOT_FOLDER}
    Wait Until Element Is Visible    css:div#robot-preview-image
    Screenshot    css:div#robot-preview-image    ${screen}
    RETURN    ${screen}

Embed the robot screenshot to the receipt PDF file
    [Documentation]    import Documentation here ....
    [Arguments]    ${pdf}    ${screen_shot}    ${index}
    ${date}=    Get Current Date
    Check for directory    ${RESULT_FOLDER}
    ${result}=    Set Variable    ${RESULT_FOLDER}/result_${index}.pdf
    ${pdf_existed}=    Does File Exist    ${pdf}
    ${png_existed}=    Does File Exist    ${screen_shot}
    IF    ${pdf_existed} and ${pdf_existed}
        Open Pdf    ${pdf}
        ${files}=    Create List
        ...    ${screen_shot}
        ...    ${pdf}
        Add Files To Pdf    ${files}    ${result}
        Log    ${date} [INFO] Created report: ${result}
    ELSE
        Log    Files does not existed.
    END

Go to order another robot
    Wait Until Element Is Visible    css:button#order-another
    Click Element    css:button#order-another

Check for directory
    [Documentation]    check for given directory existed if not created it!
    [Arguments]    ${path}
    ${directory_exists}=    Does directory not exist    ${path}
    IF    ${directory_exists}    Create directory    ${path}

Create a ZIP file of the receipts
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip
    ...    ${RESULT_FOLDER}
    ...    ${zip_file_name}

Close App
    [Documentation]    close the current working web browser
    Close Browser
