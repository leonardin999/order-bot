*** Settings ***
Documentation       Orders robots from RobotSparebin Industries Inc.
...                 Save the order HTML receipt as a PDF file.
...                 Save the screenshot of the ordered robot.
...                 Embbed the screenshot of the robot to the PDF    receipt.
...                 Creates ZIP archive of the receipts and the image.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Tables


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    TRY
        Open the robot order website
        ${orders}=    Get orders
        FOR    ${row}    IN    @{orders}
            Close the pop up
            Fill the form    ${row}
            #    Preview the robot
            #    Submit the order
            #    ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
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

Close the pop up
    [Documentation]    close the pop up when it appear!
    Wait Until Element Is Visible    css:button.btn.btn-dark
    Click Button    OK

Fill the form
    [Documentation]    complete the form with each row of data of given input
    [Arguments]    ${data}
    Select From List By Value    css:#head.custom-select    ${data}["Head"]
    Select Checkbox    css:id-body-${data}["Body"]
    Input Text    alias:Input-legs    ${data}["Legs"]
    Input Text    css:#address    ${data}["Address"]
    Click Button    css:#preview

Close App
    [Documentation]    close the current working web browser
    Close Browser
