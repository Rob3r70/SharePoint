<# =========================================================================
   ######################################################################### 
    
   ###     Created by: Robi Voncina
   ###     Company: Kompas Xnet d.o.o.
   ###     email: robi@kompas-xnet.si

   ###     Note: This script currently supports creating
   ###     site collections in WildCard Managed Paths only

   ### Version History:

   *** 1.0 - Initial
   *** 2.0 - Explicit inclusion managed paths supported 
           - script signed with certificate
   
   *** 3.0 - When creating site collection, default assosiated groups are
             created 
           - script signed with certificate

   #########################################################################
========================================================================= #>

$manPathDropDown_SelectedIndexChanged={
    if($manPathDropDown.SelectedItem.Type -eq "ExplicitInclusion"){
        $ScUrlTextBox.Enabled=$false
    }
}



function ReturnSelectedWebApp(){
    #region web app selected
    $Script:selectedWebApp=$webAppDropDown.selectedItem.ToString()

    $selectedWebApp = new-object System.Windows.Forms.Label
    $selectedWebApp.Location = new-object System.Drawing.Size(10,70) 
    $selectedWebApp.size = new-object System.Drawing.Size(300,20) 
    $selectedWebApp.Text = "Selected web application: $Script:selectedWebApp"
    $Form.Controls.Add($selectedWebApp)
    #endregion


    #region Managed path and content database
    <# =====================================================
    
    On web app reload clear drop downs and populate again

    ===================================================== #>
    if(!$Form.Controls.ContainsKey($manPathDropDown.name)){
        $manPathDropDownLabel = new-object System.Windows.Forms.Label
        $manPathDropDownLabel.Location = new-object System.Drawing.Size(10,90) 
        $manPathDropDownLabel.size = new-object System.Drawing.Size(150,20) 
        $manPathDropDownLabel.Text = "Select Managed Path"
    
        $Form.Controls.Add($manPathDropDownLabel)

    
        $manPathDropDown.Location=New-Object System.Drawing.Size(180,90)
        $manPathDropDown.Size=New-Object System.Drawing.Size(300,10)
        $manPathDropDown.Name="ManagedPathDropDown"
        
        PopulateManagedPathsDropDown

        
        $form.Controls.Add($manPathDropDown)
        $manPathDropDown.add_SelectedIndexChanged($manPathDropDown_SelectedIndexChanged)

    
        $contentDbLabel = new-object System.Windows.Forms.Label
        $contentDbLabel.Location = new-object System.Drawing.Size(10,115) 
        $contentDbLabel.size = new-object System.Drawing.Size(150,20) 
        $contentDbLabel.Text = "Select Content Database"
        $Form.Controls.Add($contentDbLabel)

    
        $contentDbDropDown.Location=New-Object System.Drawing.Size(180,115)
        $contentDbDropDown.Size=New-Object System.Drawing.Size(300,10)
        $contentDbDropDown.Name="ContentDbDropDown"
        $contentDbs=Get-SPContentDatabase -WebApplication $Script:selectedWebApp
    
        foreach($contentDb in $contentDbs){
            $contentDbDropDown.Items.Add($contentDb.name)
        }
        $form.Controls.Add($contentDbDropDown)
    }
    else{
        $manPathDropDown.Items.Clear()
        PopulateManagedPathsDropDown

        <# Old...
        foreach($managedPath in $managedPaths){
            if($managedPath.type -eq "WildcardInclusion"){
                $manPathDropDown.Items.Add($($managedPath.name)+"/")
            }
        }
        #>
        $contentDbDropDown.Items.Clear()
        $contentDbs=Get-SPContentDatabase -WebApplication $Script:selectedWebApp
        foreach($contentDb in $contentDbs){
            $contentDbDropDown.Items.Add($contentDb.name)
        }

    }
    
    #endregion
    

    #region primary and secondary site collection admin
    $primaryScAdmin = new-object System.Windows.Forms.Label
    $primaryScAdmin.Location = new-object System.Drawing.Size(10,140) 
    $primaryScAdmin.size = new-object System.Drawing.Size(150,20) 
    $primaryScAdmin.Text = "Enter primary SC admin:"
    $Form.Controls.Add($primaryScAdmin)

    
    $primaryScAdminTextBox.Location = new-object System.Drawing.Size(180,140) 
    $primaryScAdminTextBox.size = new-object System.Drawing.Size(300,20) 
    $Form.Controls.Add($primaryScAdminTextBox)
    
    $secondaryScAdmin = new-object System.Windows.Forms.Label
    $secondaryScAdmin.Location = new-object System.Drawing.Size(10,165) 
    $secondaryScAdmin.size = new-object System.Drawing.Size(150,20) 
    $secondaryScAdmin.Text = "Enter secondary SC admin:"
    $Form.Controls.Add($secondaryScAdmin)

    
    $secondaryScAdminTextBox.Location = new-object System.Drawing.Size(180,165) 
    $secondaryScAdminTextBox.size = new-object System.Drawing.Size(300,20) 
    $Form.Controls.Add($secondaryScAdminTextBox)

    #endregion

    #region site collection title
    $ScTitle = new-object System.Windows.Forms.Label
    $ScTitle.Location = new-object System.Drawing.Size(10,190) 
    $ScTitle.size = new-object System.Drawing.Size(150,20) 
    $ScTitle.Text = "Enter SC Title:"
    $Form.Controls.Add($ScTitle)

    
    $ScTitleTextBox.Location = new-object System.Drawing.Size(180,190) 
    $ScTitleTextBox.size = new-object System.Drawing.Size(300,20) 
    $Form.Controls.Add($ScTitleTextBox)
    #endregion


    #region site collection url
    $ScUrl = new-object System.Windows.Forms.Label
    $ScUrl.Location = new-object System.Drawing.Size(10,215) 
    $ScUrl.size = new-object System.Drawing.Size(150,20) 
    $ScUrl.Text = "Enter SC URL:"
    $Form.Controls.Add($ScUrl)

    
    $ScUrlTextBox.Location = new-object System.Drawing.Size(180,215) 
    $ScUrlTextBox.size = new-object System.Drawing.Size(300,20)
    if($manPathDropDown.SelectedValue -eq "ExplicitInclusion"){
        $ScUrlTextBox.Enabled=$false
    }
    $Form.Controls.Add($ScUrlTextBox)
    #endregion
        
    #region installed languages selection
    <# =====================================================

        On reload, if language drop down exists - do nothing 

    ===================================================== #>

    if(!$Form.Controls.ContainsKey($languageDropDown.name)){
        $languageLabel = new-object System.Windows.Forms.Label
        $languageLabel.Location = new-object System.Drawing.Size(10,240) 
        $languageLabel.size = new-object System.Drawing.Size(150,20) 
        $languageLabel.Text = "Select SC language:"
        $Form.Controls.Add($languageLabel)
    
        $languageDropDown.Location = new-object System.Drawing.Size(180,240) 
        $languageDropDown.size = new-object System.Drawing.Size(300,20) 
        $languageDropDown.Name="LanguageDropDown"
    
        $languages=[Microsoft.SharePoint.SPRegionalSettings]::GlobalInstalledLanguages
        foreach($lang in $languages){
            $languageDropDown.Items.Add($lang.LCID)
        }
        $Form.Controls.Add($languageDropDown)
    }
    #endregion

    #region Load web templates
    $ButtonLoadWebTempls = new-object System.Windows.Forms.Button
    $ButtonLoadWebTempls.Location = new-object System.Drawing.Size(500,240)
    $ButtonLoadWebTempls.Size = new-object System.Drawing.Size(100,20)
    $ButtonLoadWebTempls.Text = "Load Web Templates"
    $ButtonLoadWebTempls.Add_Click({LoadWebTemplates})
    $form.Controls.Add($ButtonLoadWebTempls)
    #end region
}

function PopulateManagedPathsDropDown(){
    $managedPaths=Get-SPManagedPath -WebApplication $Script:selectedWebApp
    $mpItems=@()
    foreach($managedPath in $managedPaths){
        if($managedPath.type -eq "WildcardInclusion"){
            $mpItem=new-object Object
            $mpItem |Add-Member -MemberType NoteProperty -Name ManagedPath "$($managedPath.Name)/"
            $mpItem |Add-Member -MemberType NoteProperty -Name Type $managedPath.Type
            $mpItems+=$mpItem
        }
        else{
            try{
                $spSiteUrl=$Script:selectedWebApp+$managedPath.name
                $spsite=new-object Microsoft.SharePoint.SPSite($spSiteUrl)
            }
            catch{
                $mpItem=new-object Object
                $mpItem |Add-Member -MemberType NoteProperty -Name ManagedPath "$($managedPath.Name)"
                $mpItem |Add-Member -MemberType NoteProperty -Name Type $managedPath.Type
                $mpItems+=$mpItem
            }               
        }
        
    }
        
    $manPathDropDown.DisplayMember="ManagedPath"
    $manPathDropDown.ValueMember="Type"        
    $manPathDropDown.Items.AddRange($mpItems)

}


function LoadWebTemplates(){
    #region Variables
    $script:selectedManagedPath=$manPathDropDown.SelectedItem.ManagedPath
    $script:ScURL=$ScUrlTextBox.Text
    $script:selectedLanguage=$languageDropDown.SelectedItem.tostring()
    #endregion

    #region concatenate and display site collection URL
    $ScUrlLabel = new-object System.Windows.Forms.Label
    $ScUrlLabel.Location = new-object System.Drawing.Size(10,265) 
    $ScUrlLabel.size = new-object System.Drawing.Size(300,20)
    if($manPathDropDown.SelectedValue -eq "ExplicitInclusion"){
        $script:SiteCollectionUrl="$Script:selectedWebApp$script:selectedManagedPath"
    }
    else{
        $script:SiteCollectionUrl="$Script:selectedWebApp$script:selectedManagedPath$script:ScURL"
    }    
    $ScUrlLabel.Text = "URL of new site collection: $SiteCollectionUrl"
    $Form.Controls.Add($ScUrlLabel)
    #endregion

    #region load web templates
    $webTmplLabel = new-object System.Windows.Forms.Label
    $webTmplLabel.Location = new-object System.Drawing.Size(10,290) 
    $webTmplLabel.size = new-object System.Drawing.Size(150,20) 
    $webTmplLabel.Text = "Select Web Template:"
        
    
    $WebTemplatesDropDown.Location = new-object System.Drawing.Size(180,290) 
    $WebTemplatesDropDown.size = new-object System.Drawing.Size(300,20) 
    $WebTemplatesDropDown.Name="WebTemplatesDropDown"
    

    <# =====================================================

        If control exists, reload web templates
        Load web templates based on:
            -Language: Based od dropdown selection
            -CompatibilityLevel: 15
            -isHidden: false

    ===================================================== #>
    if(!$Form.Controls.ContainsKey($WebTemplatesDropDown.Name)){
        $webTemplates=Get-SPWebTemplate |?{$_.localeId -eq $script:selectedLanguage -and $_.compatibilityLevel -eq 15 -and $_.isHidden -eq $false} |select name,title
        $items=@()
         foreach($webTemplate in $webTemplates){
            $item=new-object Object
            $item |Add-Member -MemberType NoteProperty -Name Title $webTemplate.Title
            $item |Add-Member -MemberType NoteProperty -Name Name $webTemplate.Name
            $items+=$item
        }
        $WebTemplatesDropDown.ValueMember="Name"
        $WebTemplatesDropDown.DisplayMember="Title"
        $WebTemplatesDropDown.Items.AddRange($items)

    
        $Form.Controls.Add($webTmplLabel)
        $Form.Controls.Add($WebTemplatesDropDown)    
    }
    else{
        $webTemplates=Get-SPWebTemplate |?{$_.localeId -eq $script:selectedLanguage -and $_.compatibilityLevel -eq 15 -and $_.isHidden -eq $false} |select name,title
        $items=@()
        $WebTemplatesDropDown.Items.Clear()
         foreach($webTemplate in $webTemplates){
            $item=new-object Object
            $item |Add-Member -MemberType NoteProperty -Name Title $webTemplate.Title
            $item |Add-Member -MemberType NoteProperty -Name Name $webTemplate.Name
            $items+=$item
        }
        $WebTemplatesDropDown.ValueMember="Name"
        $WebTemplatesDropDown.DisplayMember="Title"
        $WebTemplatesDropDown.Items.AddRange($items)

    }
    #end region

    #region button create site collection
    $ButtonCreateSiceCollection = new-object System.Windows.Forms.Button
    $ButtonCreateSiceCollection.Location = new-object System.Drawing.Size(300,315)
    $ButtonCreateSiceCollection.Size = new-object System.Drawing.Size(300,20)
    $ButtonCreateSiceCollection.Text = "Create site collection"
    $ButtonCreateSiceCollection.Add_Click({CreateSiteCollection})
    $form.Controls.Add($ButtonCreateSiceCollection)        
    #endregion
}

function CreateSiteCollection(){  
    #region Result label
    $resultLabel = new-object System.Windows.Forms.Label
    $resultLabel.Location = new-object System.Drawing.Size(10,340) 
    $resultLabel.size = new-object System.Drawing.Size(500,50) 
    $resultLabel.ForeColor=[System.Drawing.Color]::Red
    #endregion
    
    #region check values
    [bool]$createSc=$true
    if($script:SiteCollectionUrl -eq ""){
        $createSc=$false
        $resultLabel.Text+="You must enter site collection URL"+[System.Environment]::NewLine
    }
    if($languageDropDown.SelectedItem.ToString() -eq ""){
        $createSc=$false
        $resultLabel.Text+="You must Select language of site collection"+[System.Environment]::NewLine
    }
    if($WebTemplatesDropDown.SelectedItem.ToString() -eq ""){
        $createSc=$false
        $resultLabel.Text+="You must Select template of site collection"+[System.Environment]::NewLine
    }
    if($primaryScAdminTextBox.text -eq ""){
        $createSc=$false
        $resultLabel.Text+="You must enter primary site collection admin"+[System.Environment]::NewLine
    }
    if($ScTitleTextBox.text -eq ""){
        $createSc=$false
        $resultLabel.Text+="You must enter site collection title"+[System.Environment]::NewLine
    }
    if($contentDbDropDown.SelectedItem.ToString() -eq ""){
        $createSc=$false
        $resultLabel.Text+="You must select content database"+[System.Environment]::NewLine
    }
    #endregion
   
    #region create site collection
    if($createSc){
        try{        
            if($secondaryScAdminTextBox.Text -ne ""){
               $spsite= New-SPSite -Url $script:SiteCollectionUrl `
                -Language $languageDropDown.SelectedItem.ToString() `
                -Template $WebTemplatesDropDown.SelectedItem.Name `
                -OwnerAlias $primaryScAdminTextBox.text `
                -Name $ScTitleTextBox.Text `
                -SecondaryOwnerAlias $secondaryScAdminTextBox.Text `
                -ContentDatabase $contentDbDropDown.SelectedItem.ToString() `
                -Verbose
            }
            else{
                $spsite=New-SPSite -Url $script:SiteCollectionUrl `
                -Language $languageDropDown.SelectedItem.ToString() `
                -Template $WebTemplatesDropDown.SelectedItem.Name `
                -OwnerAlias $primaryScAdminTextBox.text `
                -Name $ScTitleTextBox.Text `
                -ContentDatabase $contentDbDropDown.SelectedItem.ToString() `
                -Verbose
            }

            #Create default Site collection groups
            $spsite.rootweb.CreateDefaultAssociatedGroups($primaryScAdminTextBox.text,"","")

            $resultLabel.Text = "Site collection created: $SiteCollectionUrl"
            $resultLabel.ForeColor=[System.Drawing.Color]::Green

            $buttonClose = new-object System.Windows.Forms.Button
            $buttonClose.Location = new-object System.Drawing.Size(300,400)
            $buttonClose.Size = new-object System.Drawing.Size(150,20)
            $buttonClose.Text = "Close form"
            $buttonClose.Add_Click({CloseForm})
            $form.Controls.Add($buttonClose)  

        }
        catch{
            $resultLabel.Text=$($_.exception.message)
            #$resultLabel.ForeColor=[System.Drawing.Color]::Red
        }
    }
    $form.Controls.Add($resultLabel)
    
    #endregion   

}

function CloseForm(){
    $form.Close()
    $form.Dispose()
}




#region load assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
#endregion

#region Form
$form=new-object System.Windows.Forms.Form
$form.Width=650
$form.Height=600
$form.Text="Create New Site Collection in Specified Content Database"
#endregion

#region Form objects
$webAppDropDownLabel = new-object System.Windows.Forms.Label
$webAppDropDown=new-object System.Windows.Forms.ComboBox
$manPathDropDown=new-object System.Windows.Forms.ComboBox
$languageDropDown=New-Object System.Windows.Forms.ComboBox
$contentDbDropDown=new-object System.Windows.Forms.ComboBox
$primaryScAdminTextBox=New-Object System.Windows.Forms.TextBox
$secondaryScAdminTextBox=New-Object System.Windows.Forms.TextBox
$ScTitleTextBox=New-Object System.Windows.Forms.TextBox
$ScUrlTextBox=New-Object System.Windows.Forms.TextBox
$WebTemplatesDropDown=new-object System.Windows.Forms.ComboBox
#endregion

#region web application
$webAppDropDownLabel.Location = new-object System.Drawing.Size(10,10) 
$webAppDropDownLabel.size = new-object System.Drawing.Size(150,20) 
$webAppDropDownLabel.Text = "Web applications:"
$Form.Controls.Add($webAppDropDownLabel)


$webAppDropDown.Location=New-Object System.Drawing.Size(170,10)
$webAppDropDown.Size=New-Object System.Drawing.Size(300,20)
#region enumarate all web apps and return web app URL of default zone
$webApps=Get-SPWebApplication
foreach($webApp in $webApps){
    $webAppDropDown.Items.Add($webApp.GetResponseUri([Microsoft.SharePoint.Administration.SPUrlZone]::Default).absoluteUri.ToString())
}
#endregion
$form.Controls.Add($webAppDropDown)
#endregion

#region Load web app properties
$Button = new-object System.Windows.Forms.Button
$Button.Location = new-object System.Drawing.Size(500,10)
$Button.Size = new-object System.Drawing.Size(100,20)
$Button.Text = "Select a web application"
$Button.Add_Click({ReturnSelectedWebApp})
$form.Controls.Add($Button)

#region load and show form
$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()
#endregion
