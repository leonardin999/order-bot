*** Settings ***
Documentation       Orders robots from RobotSparebin Industries Inc.
...                 Save the order HTML receipt as a PDF file.
...                 Save the screenshot of the ordered robot.
...                 Embbed the screenshot of the robot to the PDF    receipt.
...                 Creates ZIP archive of the receipts and the image.

Library             RPA.Browser.Selenium    auto_close=${False}


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    # ${orders}=    Get orders
    # FOR    ${row}    IN    @{orders}
    #    Close the annoying modal
    #    Fill the form    ${row}
    #    Preview the robot
    #    Submit the order
    #    ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    #    ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
    #    Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
    #    Go to order another robot
    # END
    # Create a ZIP file of the receipts


*** Keywords ***
Open the robot order website
    Open Chrome Browser    https://robotsparebinindustries.com/#/robot-order    maximized=${True}
