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
        # Create a ZIP file of the receipts
    FINALLY
        Log    Done.
        # Close App
    END


*** Keywords ***
Open the robot order website
    [Documentation]    open the target website and click the pop up
    Open Chrome Browser    https://robotsparebinindustries.com/#/robot-order    maximized=${True}
    # Click Button    OK

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
    Click Element    css:button#order
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
    ${pdf}=    ${OUTPUT_DIR}${/}receipts/order_${index}.pdf
    Check for directory    ${OUTPUT_DIR}${/}receipts
    Wait Until Element Is Visible    css:div#receipt
    ${recept_content}=    Get Element Attribute    css:div#receipt    outerHTML
    Html To Pdf    ${recept_content}    ${pdf}
    RETURN    ${pdf}

Take a screenshot of the robot
    [Documentation]    using the Scree to stored the designed robot information
    [Arguments]    ${index}
    ${screen}=    ${OUTPUT_DIR}${/}receipts/order_${index}.png
    Check for directory    ${OUTPUT_DIR}${/}screenshot
    Wait Until Element Is Visible    css:div#robot-preview-image
    Screenshot    css:div#robot-preview-image    ${screen}
    RETURN    ${screen}

Embed the robot screenshot to the receipt PDF file
    [Documentation]    import Documentation here ....
    [Arguments]    ${pdf}    ${screen_shot}    ${index}
    ${date}=    Get Current Date
    ${date}=    Convert Date    ${date}    date_format=yyyyMMdd hh:mm:ss
    Check for directory    ${OUTPUT_DIR}${/}result
    ${result}=    ${OUTPUT_DIR}${/}receipts/result_${index}.pdf
    ${pdf_existed}=    Does File Exist    ${pdf}
    ${png_existed}=    Does File Exist    ${screen_shot}
    IF    ${pdf_existed} and ${pdf_existed}
        Open Pdf    ${pdf}
        ${files}=    Create List
        ...    ${pdf}
        ...    ${screen_shot}
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

Close App
    [Documentation]    close the current working web browser
    Close Browser
