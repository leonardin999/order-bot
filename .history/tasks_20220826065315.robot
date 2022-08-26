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
            #    ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
            #    Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
            #    Go to order another robot
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

Check for directory
    [Documentation]    check for given directory existed if not created it!
    [Arguments]    ${path}
    ${directory_exists}=    Does directory not exist    ${path}
    IF    ${directory_exists}    Create directory    ${path}

Close the pop up
    [Documentation]    close the pop up when it appear!
    Wait Until Element Is Visible    css:button.btn.btn-dark
    Click Button    OK

Store the receipt as a PDF file
    [Documentation]    using the HTML to PDF Method to stored the    information
    [Arguments]    ${index}
    Check for directory    ${OUTPUT_DIR}${/}receipts
    Html To Pdf    css:div#receipt    ${OUTPUT_DIR}${/}receipts/order_${index}.pdf

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

Close App
    [Documentation]    close the current working web browser
    Close Browser
