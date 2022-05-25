Import-Module ActiveDirectory

# Hide PowerShell Console
function Hide-Console
{
    # Hide PowerShell Console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)
}

<##username Text box 
$UserTextBox = New-Object System.Windows.Forms.TextBox
$UserTextBox.Location = '23,23'
$UserTextBox.Size = '100,23'
$loginForm.Controls.Add($UserTextBox)

# Username Label
$label = New-Object Windows.Forms.Label
$label.Location = New-Object Drawing.Point 40,7
$label.Size = New-Object Drawing.Point 80,20
$label.text = "Username"
$loginForm.Controls.Add($label)
#>

Hide-Console

# Make AD Group before Name ANYTHING
# CChecks AD group if user has permission to
$userrun = $env:username
$members =  Get-ADGroupMember -Identity "ENTER AD SEC GROUP NAME" -Recursive | Select -ExpandProperty SamAccountName
#Sets Pass to null
$pass = "0"
$Password = "0"
$Username = "0"

If ($members -contains $userrun) {

    #Login GUI
    # Login Screen
    # Import forms and start new form loginform
    [reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $loginForm = New-Object System.Windows.Forms.Form
    $loginForm.Height = 250
    $loginForm.StartPosition = 'CenterScreen'

    #Password text box
    $PassTextBox = New-Object System.Windows.Forms.MaskedTextBox
        $PassTextBox.PasswordChar = '*'
        $PassTextBox.Location = '85,23'
        $PassTextBox.Size = '100,23'
        $loginForm.Controls.Add($PassTextBox)

    # Password Label
    $labelp = New-Object Windows.Forms.Label
        $labelp.Location = New-Object Drawing.Point 110,7
        $labelp.Size = New-Object Drawing.Point 80,20
        $labelp.text = "Password"
        $loginForm.Controls.Add($labelp)

    # Login Button
    $loginButton = New-Object System.Windows.Forms.Button
        $loginButton.Text = 'Login'
        $loginButton.Location = '95,60'
        $loginForm.Controls.Add($loginButton)
        $loginButton.Add_Click({
            $global:Username=$UserTextBox.Text
            $global:pass=$PassTextBox.Text
            $loginForm.Close()
        })

    # Cancel Button
    $Cancelbutton = New-Object Windows.Forms.Button
        $Cancelbutton.text = "Cancel"
        $Cancelbutton.Location = '95,90'
        $loginForm.Controls.Add($Cancelbutton)
        $CancelButton.Add_Click({$loginForm.Close()})

    # Shows GUI
    Hide-Console
    $loginForm.ShowDialog() | Out-Null

    # AD Login (Hard Coded Username as user must have elevated privileges)
    $Username = "DOMAIN\USER"
    #$pass = Get-Content pass1.txt
    $Password = ConvertTo-SecureString -String $pass -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($Username, $Password)


    # GUI
    Add-Type -assembly System.Windows.Forms
    $main_form = New-Object System.Windows.Forms.Form
        $main_form.Text ='Off-Boarding'
        $main_form.Width = 600
        $main_form.Height = 400
        $main_form.AutoSize = $true
        $Label = New-Object System.Windows.Forms.Label
        $Label.Text = "AD user"
        $Label.Location  = New-Object System.Drawing.Point(0,10)
        $Label.AutoSize = $true
        $main_form.Controls.Add($Label)

    # Button
    $Button = New-Object System.Windows.Forms.Button
        $Button.Location = New-Object System.Drawing.Size(400,10)
        $Button.Size = New-Object System.Drawing.Size(120,23)
        $Button.Text = "Disable"
        $main_form.Controls.Add($Button)

    # Cancel Button
    $Cancelbutton = New-Object Windows.Forms.Button
        $Cancelbutton.text = "Cancel"
        $Cancelbutton.Location = '400,40'
        $Cancelbutton.Size = New-Object System.Drawing.Size(120,23)
        $main_form.Controls.Add($Cancelbutton)
        $CancelButton.Add_Click({$main_form.Close()})

    # Display Action
    $Label2 = New-Object System.Windows.Forms.Label
        $Label2.Text = "User Disabled:"
        $Label2.Location  = New-Object System.Drawing.Point(0,40)
        $Label2.AutoSize = $true
        $main_form.Controls.Add($Label2)
        $Label3 = New-Object System.Windows.Forms.Label
        $Label3.Text = ""
        $Label3.Location  = New-Object System.Drawing.Point(110,40)
        $Label3.AutoSize = $true
        $main_form.Controls.Add($Label3)

    #Drop Down List (Used so user can select correct user)
    $ComboBox = New-Object System.Windows.Forms.ComboBox
    $ComboBox.Width = 300
    $Users = get-aduser -filter * -searchbase (Get-ADOrganizationalUnit -filter "name -eq 'NAME OF OU OR MAIN OU'") -Properties SamAccountName

    Foreach ($User in $Users)
    {
        $ComboBox.Items.Add($User.SamAccountName);
    }
    $ComboBox.Location  = New-Object System.Drawing.Point(60,10)
    $main_form.Controls.Add($ComboBox)


    # Button Click
    $Button.Add_Click(
    {
        $mesg = "Are you sure you would like to disable " + $ComboBox.selectedItem 
        $OUTPUT= [System.Windows.Forms.MessageBox]::Show($mesg , "Warning" , 4, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($OUTPUT -eq "YES" )
        {
            
            #get-aduser -filter * -Properties SamAccountName
            #get-aduser -filter * -Properties SamAccountName
            $u = $ComboBox.selectedItem + ". " + $userrun + " Made this change"
            $Label3.Text = $u

            $Username1 = " "
            $pass1 = " "
            $Password1 = ConvertTo-SecureString -String $pass1 -AsPlainText -Force
            $credential1 = New-Object System.Management.Automation.PSCredential($Username1, $Password1)

            # Sends email to sys admins (Not working, Could also use Teams)
            #$email2 = 'EMAIL FROM'
            #$email = 'EMAIL TO'
            #Send-MailMessage -To $email -From $email2 -Subject 'Disabled User' -Body "test" -Credential $credential1 -SmtpServer 'MAIL SERVER'


        }else{
            return
        } 
    }
    )

    # Show GUI
    $main_form.ShowDialog() | Out-Null
    Hide-Console

}else{
    [System.Windows.Forms.MessageBox]::Show("You Do not have Permission To run" , "Error Permission" , 0,[System.Windows.Forms.MessageBoxIcon]::Error)
}