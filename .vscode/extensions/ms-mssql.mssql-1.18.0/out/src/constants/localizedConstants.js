"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.loadLocalizedConstants = exports.reloadChoice = exports.reloadPrompt = exports.showOutputChannelActionButtonText = exports.objectExplorerNodeRefreshError = exports.columnWidthMustBePositiveError = exports.columnWidthInvalidNumberError = exports.newColumnWidthPrompt = exports.msgMultipleSelectionModeNotSupported = exports.connectProgressNoticationTitle = exports.msgClearedRecentConnectionsWithErrors = exports.deleteCredentialError = exports.nodeErrorMessage = exports.notStarted = exports.canceling = exports.inProgress = exports.canceled = exports.succeededWithWarning = exports.succeeded = exports.failed = exports.taskStatusWithNameAndMessage = exports.taskStatusWithMessage = exports.taskStatusWithName = exports.azureSignInToAzureCloudDescription = exports.azureSignInToAzureCloud = exports.azureSignInWithDeviceCodeDescription = exports.azureSignInWithDeviceCode = exports.azureSignInDescription = exports.azureSignIn = exports.msgConnect = exports.msgAddConnection = exports.flavorDescriptionNone = exports.flavorDescriptionMssql = exports.flavorChooseLanguage = exports.noneProviderName = exports.mssqlProviderName = exports.msgCannotSaveMultipleSelections = exports.elapsedTimeLabel = exports.lineSelectorFormatted = exports.messagesTableMessageColumn = exports.messagesTableTimeStampColumn = exports.messagePaneLabel = exports.QueryExecutedLabel = exports.executeQueryLabel = exports.copyWithHeadersLabel = exports.copyLabel = exports.selectAll = exports.resultPaneLabel = exports.fileTypeExcelLabel = exports.fileTypeJSONLabel = exports.fileTypeCSVLabel = exports.saveExcelLabel = exports.saveJSONLabel = exports.saveCSVLabel = exports.restoreLabel = exports.maximizeLabel = exports.noActiveEditorMsg = exports.elapsedBatchTime = exports.disconnectConfirmationMsg = exports.disconnectOptionDescription = exports.disconnectOptionLabel = exports.testLocalizationConstant = exports.intelliSenseUpdatedStatus = exports.updatingIntelliSenseStatus = exports.definitionRequestCompletedStatus = exports.definitionRequestedStatus = exports.gettingDefinitionMessage = exports.macSierraRequiredErrorMessage = exports.macOpenSslHelpButton = exports.macOpenSslErrorMessage = exports.msgDisconnected = exports.msgChangedDatabase = exports.msgChangingDatabase = exports.msgConnectionFailed = exports.msgConnectedServerInfo = exports.msgRefreshTokenNotNeeded = exports.msgRefreshTokenSuccess = exports.msgRefreshConnection = exports.msgAzureCredStoreSaveFailedError = exports.msgRefreshTokenError = exports.msgAcessTokenExpired = exports.msgFoundPendingReconnectError = exports.msgFoundPendingReconnectFailed = exports.msgPendingReconnectSuccess = exports.msgFoundPendingReconnect = exports.msgConnectionNotFound = exports.msgConnecting = exports.createFirewallRuleLabel = exports.retryLabel = exports.msgNoQueriesAvailable = exports.msgInvalidIpAddress = exports.msgRunQueryHistory = exports.msgOpenQueryHistory = exports.msgChooseQueryHistoryAction = exports.msgChooseQueryHistory = exports.msgAccountNotFound = exports.msgPromptFirewallRuleCreated = exports.msgUnableToExpand = exports.msgPromptProfileUpdateFailed = exports.msgAccountRefreshFailed = exports.msgPromptRetryFirewallRuleAdded = exports.msgPromptRetryFirewallRuleSignedIn = exports.msgPromptRetryFirewallRuleNotSignedIn = exports.msgPromptSSLCertificateValidationFailed = exports.msgPromptRetryConnectionDifferentCredentials = exports.msgGetTokenFail = exports.refreshTokenLabel = exports.msgPromptRetryCreateProfile = exports.msgChangedDatabaseContext = exports.msgChangeLanguageMode = exports.untitledScheme = exports.extensionNotInitializedError = exports.updatingIntelliSenseLabel = exports.cancelingQueryLabel = exports.connectErrorMessage = exports.connectErrorCode = exports.connectErrorTooltip = exports.connectErrorLabel = exports.connectingTooltip = exports.connectingLabel = exports.notConnectedTooltip = exports.notConnectedLabel = exports.defaultDatabaseLabel = exports.msgNo = exports.msgYes = exports.msgError = exports.msgIsRequired = exports.msgClearedRecentConnections = exports.msgProfileCreatedAndConnected = exports.msgProfileCreated = exports.msgProfileRemoved = exports.msgNoProfilesSaved = exports.confirmRemoveProfilePrompt = exports.msgSelectProfileToRemove = exports.msgSaveSucceeded = exports.msgSaveFailed = exports.msgSaveStarted = exports.msgCannotOpenContent = exports.profileNamePlaceholder = exports.profileNamePrompt = exports.msgSavePassword = exports.passwordPlaceholder = exports.passwordPrompt = exports.usernamePlaceholder = exports.usernamePrompt = exports.tenant = exports.azureChooseTenant = exports.aad = exports.cannotConnect = exports.noAzureAccountForRemoval = exports.accountRemovalFailed = exports.accountRemovedSuccessfully = exports.accountCouldNotBeAdded = exports.accountAddedSuccessfully = exports.azureAddAccount = exports.azureChooseAccount = exports.msgCopyAndOpenWebpage = exports.cancel = exports.readMore = exports.enableTrustServerCertificate = exports.encryptMandatoryRecommended = exports.encryptMandatory = exports.encryptOptional = exports.encryptName = exports.encryptPrompt = exports.azureAuthStateError = exports.azureAuthNonceError = exports.azureServerCouldNotStart = exports.azureNoMicrosoftResource = exports.azureMicrosoftAccount = exports.azureMicrosoftCorpAccount = exports.azureConsentDialogBody = exports.azureConsentDialogIgnore = exports.azureConsentDialogCancel = exports.azureConsentDialogOpen = exports.azureLogChannelName = exports.azureAuthTypeDeviceCode = exports.azureAuthTypeCodeGrant = exports.authTypeAzureActiveDirectory = exports.authTypeSql = exports.authTypeIntegrated = exports.authTypeName = exports.authTypePrompt = exports.databasePlaceholder = exports.endIpAddressPrompt = exports.startIpAddressPrompt = exports.databasePrompt = exports.serverPlaceholder = exports.serverPrompt = exports.SampleServerName = exports.ManageProfilesPrompt = exports.RemoveProfileLabel = exports.EditProfilesLabel = exports.ClearRecentlyUsedLabel = exports.CreateProfileLabel = exports.CreateProfileFromConnectionsListLabel = exports.recentConnectionsPlaceholder = exports.msgOpenSqlFile = exports.msgPromptClearRecentConnections = exports.msgPromptCancelConnect = exports.connectionErrorChannelName = exports.msgConnectionErrorPasswordExpired = exports.msgConnectionError2 = exports.msgConnectionError = exports.msgChooseDatabasePlaceholder = exports.msgChooseDatabaseNotConnected = exports.msgCancelQueryNotRunning = exports.msgCancelQueryFailed = exports.runQueryBatchStartLine = exports.runQueryBatchStartMessage = exports.msgRunQueryInProgress = exports.msgFinishedExecute = exports.msgStartedExecute = exports.moreInformation = exports.encryptionChangePromptDescription = exports.releaseNotesPromptDescription = exports.viewMore = void 0;
/* tslint:disable */
// THIS IS A COMPUTER GENERATED FILE. CHANGES IN THIS FILE WILL BE OVERWRITTEN.
// TO ADD LOCALIZED CONSTANTS, ADD YOUR CONSTANT TO THE ENU XLIFF FILE UNDER ~/localization/xliff/enu/constants/localizedConstants.enu.xlf AND REBUILD THE PROJECT
const nls = require("vscode-nls");
exports.viewMore = 'View more';
exports.releaseNotesPromptDescription = 'View mssql for Visual Studio Code release notes?';
exports.encryptionChangePromptDescription = 'mssql extension for VS Code now has encryption enabled by default for all SQL Server connections. This may result in your existing connections no longer working unless certain Encryption related connection properties are changed. We recommend you visit the link below for more information.';
exports.moreInformation = 'More information';
exports.msgStartedExecute = 'Started query execution for document "{0}"';
exports.msgFinishedExecute = 'Finished query execution for document "{0}"';
exports.msgRunQueryInProgress = 'A query is already running for this editor session. Please cancel this query or wait for its completion.';
exports.runQueryBatchStartMessage = 'Started executing query at ';
exports.runQueryBatchStartLine = 'Line {0}';
exports.msgCancelQueryFailed = 'Canceling the query failed: {0}';
exports.msgCancelQueryNotRunning = 'Cannot cancel query as no query is running.';
exports.msgChooseDatabaseNotConnected = 'No connection was found. Please connect to a server first.';
exports.msgChooseDatabasePlaceholder = 'Choose a database from the list below';
exports.msgConnectionError = 'Error {0}: {1}';
exports.msgConnectionError2 = 'Failed to connect: {0}';
exports.msgConnectionErrorPasswordExpired = 'Error {0}: {1} Please login as a different user and change the password using ALTER LOGIN.';
exports.connectionErrorChannelName = 'Connection Errors';
exports.msgPromptCancelConnect = 'Server connection in progress. Do you want to cancel?';
exports.msgPromptClearRecentConnections = 'Confirm to clear recent connections list';
exports.msgOpenSqlFile = 'To use this command, Open a .sql file -or- Change editor language to "SQL" -or- Select T-SQL text in the active SQL editor.';
exports.recentConnectionsPlaceholder = 'Choose a connection profile from the list below';
exports.CreateProfileFromConnectionsListLabel = 'Create Connection Profile';
exports.CreateProfileLabel = 'Create';
exports.ClearRecentlyUsedLabel = 'Clear Recent Connections List';
exports.EditProfilesLabel = 'Edit';
exports.RemoveProfileLabel = 'Remove';
exports.ManageProfilesPrompt = 'Manage Connection Profiles';
exports.SampleServerName = '{{put-server-name-here}}';
exports.serverPrompt = 'Server name or ADO.NET connection string';
exports.serverPlaceholder = 'hostname\\instance or <server>.database.windows.net or ADO.NET connection string';
exports.databasePrompt = 'Database name';
exports.startIpAddressPrompt = 'Start IP';
exports.endIpAddressPrompt = 'End IP';
exports.databasePlaceholder = '[Optional] Database to connect (press Enter to connect to <default> database)';
exports.authTypePrompt = 'Authentication Type';
exports.authTypeName = 'authenticationType';
exports.authTypeIntegrated = 'Integrated';
exports.authTypeSql = 'SQL Login';
exports.authTypeAzureActiveDirectory = 'Azure Active Directory - Universal w/ MFA Support';
exports.azureAuthTypeCodeGrant = 'Azure Code Grant';
exports.azureAuthTypeDeviceCode = 'Azure Device Code';
exports.azureLogChannelName = 'Azure Logs';
exports.azureConsentDialogOpen = 'Open';
exports.azureConsentDialogCancel = 'Cancel';
exports.azureConsentDialogIgnore = 'Ignore Tenant';
exports.azureConsentDialogBody = 'Your tenant \'{0} ({1})\' requires you to re-authenticate again to access {2} resources. Press Open to start the authentication process.';
exports.azureMicrosoftCorpAccount = 'Microsoft Corp';
exports.azureMicrosoftAccount = 'Microsoft Account';
exports.azureNoMicrosoftResource = 'Provider \'{0}\' does not have a Microsoft resource endpoint defined.';
exports.azureServerCouldNotStart = 'Server could not start. This could be a permissions error or an incompatibility on your system. You can try enabling device code authentication from settings.';
exports.azureAuthNonceError = 'Authentication failed due to a nonce mismatch, please close Azure Data Studio and try again.';
exports.azureAuthStateError = 'Authentication failed due to a state mismatch, please close ADS and try again.';
exports.encryptPrompt = 'Encrypt';
exports.encryptName = 'encrypt';
exports.encryptOptional = 'Optional (False)';
exports.encryptMandatory = 'Mandatory (True)';
exports.encryptMandatoryRecommended = 'Mandatory (Recommended)';
exports.enableTrustServerCertificate = 'Enable Trust Server Certificate';
exports.readMore = 'Read more';
exports.cancel = 'Cancel';
exports.msgCopyAndOpenWebpage = 'Copy code and open webpage';
exports.azureChooseAccount = 'Choose an Azure Active Directory Account';
exports.azureAddAccount = 'Add an Account...';
exports.accountAddedSuccessfully = 'Azure account {0} successfully added.';
exports.accountCouldNotBeAdded = 'New Azure account could not be added.';
exports.accountRemovedSuccessfully = 'Selected Azure Account removed successfully.';
exports.accountRemovalFailed = 'An error occurred while removing user account: {0}';
exports.noAzureAccountForRemoval = 'No Azure Account can be found for removal.';
exports.cannotConnect = 'Cannot connect due to expired tokens. Please re-authenticate and try again.';
exports.aad = 'AAD';
exports.azureChooseTenant = 'Choose an Azure tenant';
exports.tenant = 'Tenant';
exports.usernamePrompt = 'User name';
exports.usernamePlaceholder = 'User name (SQL Login)';
exports.passwordPrompt = 'Password';
exports.passwordPlaceholder = 'Password (SQL Login)';
exports.msgSavePassword = 'Save Password? If \'No\', password will be required each time you connect';
exports.profileNamePrompt = 'Profile Name';
exports.profileNamePlaceholder = '[Optional] Enter a display name for this connection profile';
exports.msgCannotOpenContent = 'Error occurred opening content in editor.';
exports.msgSaveStarted = 'Started saving results to ';
exports.msgSaveFailed = 'Failed to save results. ';
exports.msgSaveSucceeded = 'Successfully saved results to ';
exports.msgSelectProfileToRemove = 'Select profile to remove';
exports.confirmRemoveProfilePrompt = 'Confirm to remove this profile.';
exports.msgNoProfilesSaved = 'No connection profile to remove.';
exports.msgProfileRemoved = 'Profile removed successfully';
exports.msgProfileCreated = 'Profile created successfully';
exports.msgProfileCreatedAndConnected = 'Profile created and connected';
exports.msgClearedRecentConnections = 'Recent connections list cleared';
exports.msgIsRequired = ' is required.';
exports.msgError = 'Error: ';
exports.msgYes = 'Yes';
exports.msgNo = 'No';
exports.defaultDatabaseLabel = '<default>';
exports.notConnectedLabel = 'Disconnected';
exports.notConnectedTooltip = 'Click to connect to a database';
exports.connectingLabel = 'Connecting';
exports.connectingTooltip = 'Connecting to: ';
exports.connectErrorLabel = 'Connection error';
exports.connectErrorTooltip = 'Error connecting to: ';
exports.connectErrorCode = 'Error code: ';
exports.connectErrorMessage = 'Error Message: ';
exports.cancelingQueryLabel = 'Canceling query ';
exports.updatingIntelliSenseLabel = 'Updating IntelliSense...';
exports.extensionNotInitializedError = 'Unable to execute the command while the extension is initializing. Please try again later.';
exports.untitledScheme = 'untitled';
exports.msgChangeLanguageMode = 'To use this command, you must set the language to "SQL". Confirm to change language mode.';
exports.msgChangedDatabaseContext = 'Changed database context to "{0}" for document "{1}"';
exports.msgPromptRetryCreateProfile = 'Error: Unable to connect using the connection information provided. Retry profile creation?';
exports.refreshTokenLabel = 'Refresh Credentials';
exports.msgGetTokenFail = 'Failed to fetch user tokens.';
exports.msgPromptRetryConnectionDifferentCredentials = 'Error: Login failed. Retry using different credentials?';
exports.msgPromptSSLCertificateValidationFailed = 'Encryption was enabled on this connection, review your SSL and certificate configuration for the target SQL Server, or set \'Trust server certificate\' to \'true\' in the settings file. Note: A self-signed certificate offers only limited protection and is not a recommended practice for production environments. Do you want to enable \'Trust server certificate\' on this connection and retry?';
exports.msgPromptRetryFirewallRuleNotSignedIn = 'Your client IP address does not have access to the server. Add an Azure account and create a new firewall rule to enable access.';
exports.msgPromptRetryFirewallRuleSignedIn = 'Account signed In. Create new firewall rule? ';
exports.msgPromptRetryFirewallRuleAdded = 'Firewall rule successfully added. Retry profile creation? ';
exports.msgAccountRefreshFailed = 'Credential Error: An error occurred while attempting to refresh account credentials. Please re-authenticate.';
exports.msgPromptProfileUpdateFailed = 'Connection Profile could not be updated. Please modify the connection details manually in settings.json and try again.';
exports.msgUnableToExpand = 'Unable to expand. Please check logs for more information.';
exports.msgPromptFirewallRuleCreated = 'Firewall rule successfully created.';
exports.msgAccountNotFound = 'Account not found';
exports.msgChooseQueryHistory = 'Choose Query History';
exports.msgChooseQueryHistoryAction = 'Choose An Action';
exports.msgOpenQueryHistory = 'Open Query History';
exports.msgRunQueryHistory = 'Run Query History';
exports.msgInvalidIpAddress = 'Invalid IP Address ';
exports.msgNoQueriesAvailable = 'No Queries Available';
exports.retryLabel = 'Retry';
exports.createFirewallRuleLabel = 'Create Firewall Rule';
exports.msgConnecting = 'Connecting to server "{0}" on document "{1}".';
exports.msgConnectionNotFound = 'Connection not found for uri "{0}".';
exports.msgFoundPendingReconnect = 'Found pending reconnect promise for uri {0}, waiting.';
exports.msgPendingReconnectSuccess = 'Previous pending reconnection for uri {0}, succeeded.';
exports.msgFoundPendingReconnectFailed = 'Found pending reconnect promise for uri {0}, failed.';
exports.msgFoundPendingReconnectError = 'Previous pending reconnect promise for uri {0} is rejected with error {1}, will attempt to reconnect if necessary.';
exports.msgAcessTokenExpired = 'Access token expired for connection {0} with uri {1}';
exports.msgRefreshTokenError = 'Error when refreshing token';
exports.msgAzureCredStoreSaveFailedError = 'Keys for token cache could not be saved in credential store, this may cause Azure access token persistence issues and connection instabilities. It\'s likely that SqlTools has reached credential storage limit on Windows, please clear at least 2 credentials that start with "Microsoft.SqlTools|" in Windows Credential Manager and reload.';
exports.msgRefreshConnection = 'Failed to refresh connection ${0} with uri {1}, invalid connection result.';
exports.msgRefreshTokenSuccess = 'Successfully refreshed token for connection {0} with uri {1}, {2}';
exports.msgRefreshTokenNotNeeded = 'No need to refresh Azure acccount token for connection {0} with uri {1}';
exports.msgConnectedServerInfo = 'Connected to server "{0}" on document "{1}". Server information: {2}';
exports.msgConnectionFailed = 'Error connecting to server "{0}". Details: {1}';
exports.msgChangingDatabase = 'Changing database context to "{0}" on server "{1}" on document "{2}".';
exports.msgChangedDatabase = 'Changed database context to "{0}" on server "{1}" on document "{2}".';
exports.msgDisconnected = 'Disconnected on document "{0}"';
exports.macOpenSslErrorMessage = 'OpenSSL version >=1.0.1 is required to connect.';
exports.macOpenSslHelpButton = 'Help';
exports.macSierraRequiredErrorMessage = 'macOS Sierra or newer is required to use this feature.';
exports.gettingDefinitionMessage = 'Getting definition ...';
exports.definitionRequestedStatus = 'DefinitionRequested';
exports.definitionRequestCompletedStatus = 'DefinitionRequestCompleted';
exports.updatingIntelliSenseStatus = 'updatingIntelliSense';
exports.intelliSenseUpdatedStatus = 'intelliSenseUpdated';
exports.testLocalizationConstant = 'test';
exports.disconnectOptionLabel = 'Disconnect';
exports.disconnectOptionDescription = 'Close the current connection';
exports.disconnectConfirmationMsg = 'Are you sure you want to disconnect?';
exports.elapsedBatchTime = 'Batch execution time: {0}';
exports.noActiveEditorMsg = 'A SQL editor must have focus before executing this command';
exports.maximizeLabel = 'Maximize';
exports.restoreLabel = 'Restore';
exports.saveCSVLabel = 'Save as CSV';
exports.saveJSONLabel = 'Save as JSON';
exports.saveExcelLabel = 'Save as Excel';
exports.fileTypeCSVLabel = 'CSV';
exports.fileTypeJSONLabel = 'JSON';
exports.fileTypeExcelLabel = 'Excel';
exports.resultPaneLabel = 'Results';
exports.selectAll = 'Select all';
exports.copyLabel = 'Copy';
exports.copyWithHeadersLabel = 'Copy with Headers';
exports.executeQueryLabel = 'Executing query...';
exports.QueryExecutedLabel = 'Query executed';
exports.messagePaneLabel = 'Messages';
exports.messagesTableTimeStampColumn = 'Timestamp';
exports.messagesTableMessageColumn = 'Message';
exports.lineSelectorFormatted = 'Line {0}';
exports.elapsedTimeLabel = 'Total execution time: {0}';
exports.msgCannotSaveMultipleSelections = 'Save results command cannot be used with multiple selections.';
exports.mssqlProviderName = 'MSSQL';
exports.noneProviderName = 'None';
exports.flavorChooseLanguage = 'Choose SQL Language';
exports.flavorDescriptionMssql = 'Use T-SQL intellisense and syntax error checking on current document';
exports.flavorDescriptionNone = 'Disable intellisense and syntax error checking on current document';
exports.msgAddConnection = 'Add Connection';
exports.msgConnect = 'Connect';
exports.azureSignIn = 'Azure: Sign In';
exports.azureSignInDescription = 'Sign in to your Azure subscription';
exports.azureSignInWithDeviceCode = 'Azure: Sign In with Device Code';
exports.azureSignInWithDeviceCodeDescription = 'Sign in to your Azure subscription with a device code. Use this in setups where the Sign In command does not work';
exports.azureSignInToAzureCloud = 'Azure: Sign In to Azure Cloud';
exports.azureSignInToAzureCloudDescription = 'Sign in to your Azure subscription in one of the sovereign clouds.';
exports.taskStatusWithName = '{0}: {1}';
exports.taskStatusWithMessage = '{1}. {2}';
exports.taskStatusWithNameAndMessage = '{0}: {1}. {2}';
exports.failed = 'Failed';
exports.succeeded = 'Succeeded';
exports.succeededWithWarning = 'Succeeded with warning';
exports.canceled = 'Canceled';
exports.inProgress = 'In progress';
exports.canceling = 'Canceling';
exports.notStarted = 'Not started';
exports.nodeErrorMessage = 'Parent node was not TreeNodeInfo.';
exports.deleteCredentialError = 'Failed to delete credential with id: {0}. {1}';
exports.msgClearedRecentConnectionsWithErrors = 'The recent connections list has been cleared but there were errors while deleting some associated credentials. View the errors in the MSSQL output channel.';
exports.connectProgressNoticationTitle = 'Testing connection profile...';
exports.msgMultipleSelectionModeNotSupported = 'Running query is not supported when the editor is in multiple selection mode.';
exports.newColumnWidthPrompt = 'Enter new column width';
exports.columnWidthInvalidNumberError = 'Invalid column width';
exports.columnWidthMustBePositiveError = 'Width cannot be 0 or negative';
exports.objectExplorerNodeRefreshError = 'An error occurred refreshing nodes. See the MSSQL output channel for more details.';
exports.showOutputChannelActionButtonText = 'Show MSSQL output';
exports.reloadPrompt = 'Authentication Library has changed, please reload Visual Studio Code.';
exports.reloadChoice = 'Reload Visual Studio Code';
exports.loadLocalizedConstants = (locale) => {
    let localize = nls.config({ locale: locale })(__filename);
    exports.viewMore = localize(0, null);
    exports.releaseNotesPromptDescription = localize(1, null);
    exports.encryptionChangePromptDescription = localize(2, null);
    exports.moreInformation = localize(3, null);
    exports.msgStartedExecute = localize(4, null);
    exports.msgFinishedExecute = localize(5, null);
    exports.msgRunQueryInProgress = localize(6, null);
    exports.runQueryBatchStartMessage = localize(7, null);
    exports.runQueryBatchStartLine = localize(8, null);
    exports.msgCancelQueryFailed = localize(9, null);
    exports.msgCancelQueryNotRunning = localize(10, null);
    exports.msgChooseDatabaseNotConnected = localize(11, null);
    exports.msgChooseDatabasePlaceholder = localize(12, null);
    exports.msgConnectionError = localize(13, null);
    exports.msgConnectionError2 = localize(14, null);
    exports.msgConnectionErrorPasswordExpired = localize(15, null);
    exports.connectionErrorChannelName = localize(16, null);
    exports.msgPromptCancelConnect = localize(17, null);
    exports.msgPromptClearRecentConnections = localize(18, null);
    exports.msgOpenSqlFile = localize(19, null);
    exports.recentConnectionsPlaceholder = localize(20, null);
    exports.CreateProfileFromConnectionsListLabel = localize(21, null);
    exports.CreateProfileLabel = localize(22, null);
    exports.ClearRecentlyUsedLabel = localize(23, null);
    exports.EditProfilesLabel = localize(24, null);
    exports.RemoveProfileLabel = localize(25, null);
    exports.ManageProfilesPrompt = localize(26, null);
    exports.SampleServerName = localize(27, null);
    exports.serverPrompt = localize(28, null);
    exports.serverPlaceholder = localize(29, null);
    exports.databasePrompt = localize(30, null);
    exports.startIpAddressPrompt = localize(31, null);
    exports.endIpAddressPrompt = localize(32, null);
    exports.databasePlaceholder = localize(33, null);
    exports.authTypePrompt = localize(34, null);
    exports.authTypeName = localize(35, null);
    exports.authTypeIntegrated = localize(36, null);
    exports.authTypeSql = localize(37, null);
    exports.authTypeAzureActiveDirectory = localize(38, null);
    exports.azureAuthTypeCodeGrant = localize(39, null);
    exports.azureAuthTypeDeviceCode = localize(40, null);
    exports.azureLogChannelName = localize(41, null);
    exports.azureConsentDialogOpen = localize(42, null);
    exports.azureConsentDialogCancel = localize(43, null);
    exports.azureConsentDialogIgnore = localize(44, null);
    exports.azureConsentDialogBody = localize(45, null);
    exports.azureMicrosoftCorpAccount = localize(46, null);
    exports.azureMicrosoftAccount = localize(47, null);
    exports.azureNoMicrosoftResource = localize(48, null);
    exports.azureServerCouldNotStart = localize(49, null);
    exports.azureAuthNonceError = localize(50, null);
    exports.azureAuthStateError = localize(51, null);
    exports.encryptPrompt = localize(52, null);
    exports.encryptName = localize(53, null);
    exports.encryptOptional = localize(54, null);
    exports.encryptMandatory = localize(55, null);
    exports.encryptMandatoryRecommended = localize(56, null);
    exports.enableTrustServerCertificate = localize(57, null);
    exports.readMore = localize(58, null);
    exports.cancel = localize(59, null);
    exports.msgCopyAndOpenWebpage = localize(60, null);
    exports.azureChooseAccount = localize(61, null);
    exports.azureAddAccount = localize(62, null);
    exports.accountAddedSuccessfully = localize(63, null);
    exports.accountCouldNotBeAdded = localize(64, null);
    exports.accountRemovedSuccessfully = localize(65, null);
    exports.accountRemovalFailed = localize(66, null);
    exports.noAzureAccountForRemoval = localize(67, null);
    exports.cannotConnect = localize(68, null);
    exports.aad = localize(69, null);
    exports.azureChooseTenant = localize(70, null);
    exports.tenant = localize(71, null);
    exports.usernamePrompt = localize(72, null);
    exports.usernamePlaceholder = localize(73, null);
    exports.passwordPrompt = localize(74, null);
    exports.passwordPlaceholder = localize(75, null);
    exports.msgSavePassword = localize(76, null);
    exports.profileNamePrompt = localize(77, null);
    exports.profileNamePlaceholder = localize(78, null);
    exports.msgCannotOpenContent = localize(79, null);
    exports.msgSaveStarted = localize(80, null);
    exports.msgSaveFailed = localize(81, null);
    exports.msgSaveSucceeded = localize(82, null);
    exports.msgSelectProfileToRemove = localize(83, null);
    exports.confirmRemoveProfilePrompt = localize(84, null);
    exports.msgNoProfilesSaved = localize(85, null);
    exports.msgProfileRemoved = localize(86, null);
    exports.msgProfileCreated = localize(87, null);
    exports.msgProfileCreatedAndConnected = localize(88, null);
    exports.msgClearedRecentConnections = localize(89, null);
    exports.msgIsRequired = localize(90, null);
    exports.msgError = localize(91, null);
    exports.msgYes = localize(92, null);
    exports.msgNo = localize(93, null);
    exports.defaultDatabaseLabel = localize(94, null);
    exports.notConnectedLabel = localize(95, null);
    exports.notConnectedTooltip = localize(96, null);
    exports.connectingLabel = localize(97, null);
    exports.connectingTooltip = localize(98, null);
    exports.connectErrorLabel = localize(99, null);
    exports.connectErrorTooltip = localize(100, null);
    exports.connectErrorCode = localize(101, null);
    exports.connectErrorMessage = localize(102, null);
    exports.cancelingQueryLabel = localize(103, null);
    exports.updatingIntelliSenseLabel = localize(104, null);
    exports.extensionNotInitializedError = localize(105, null);
    exports.untitledScheme = localize(106, null);
    exports.msgChangeLanguageMode = localize(107, null);
    exports.msgChangedDatabaseContext = localize(108, null);
    exports.msgPromptRetryCreateProfile = localize(109, null);
    exports.refreshTokenLabel = localize(110, null);
    exports.msgGetTokenFail = localize(111, null);
    exports.msgPromptRetryConnectionDifferentCredentials = localize(112, null);
    exports.msgPromptSSLCertificateValidationFailed = localize(113, null);
    exports.msgPromptRetryFirewallRuleNotSignedIn = localize(114, null);
    exports.msgPromptRetryFirewallRuleSignedIn = localize(115, null);
    exports.msgPromptRetryFirewallRuleAdded = localize(116, null);
    exports.msgAccountRefreshFailed = localize(117, null);
    exports.msgPromptProfileUpdateFailed = localize(118, null);
    exports.msgUnableToExpand = localize(119, null);
    exports.msgPromptFirewallRuleCreated = localize(120, null);
    exports.msgAccountNotFound = localize(121, null);
    exports.msgChooseQueryHistory = localize(122, null);
    exports.msgChooseQueryHistoryAction = localize(123, null);
    exports.msgOpenQueryHistory = localize(124, null);
    exports.msgRunQueryHistory = localize(125, null);
    exports.msgInvalidIpAddress = localize(126, null);
    exports.msgNoQueriesAvailable = localize(127, null);
    exports.retryLabel = localize(128, null);
    exports.createFirewallRuleLabel = localize(129, null);
    exports.msgConnecting = localize(130, null);
    exports.msgConnectionNotFound = localize(131, null);
    exports.msgFoundPendingReconnect = localize(132, null);
    exports.msgPendingReconnectSuccess = localize(133, null);
    exports.msgFoundPendingReconnectFailed = localize(134, null);
    exports.msgFoundPendingReconnectError = localize(135, null);
    exports.msgAcessTokenExpired = localize(136, null);
    exports.msgRefreshTokenError = localize(137, null);
    exports.msgAzureCredStoreSaveFailedError = localize(138, null);
    exports.msgRefreshConnection = localize(139, null);
    exports.msgRefreshTokenSuccess = localize(140, null);
    exports.msgRefreshTokenNotNeeded = localize(141, null);
    exports.msgConnectedServerInfo = localize(142, null);
    exports.msgConnectionFailed = localize(143, null);
    exports.msgChangingDatabase = localize(144, null);
    exports.msgChangedDatabase = localize(145, null);
    exports.msgDisconnected = localize(146, null);
    exports.macOpenSslErrorMessage = localize(147, null);
    exports.macOpenSslHelpButton = localize(148, null);
    exports.macSierraRequiredErrorMessage = localize(149, null);
    exports.gettingDefinitionMessage = localize(150, null);
    exports.definitionRequestedStatus = localize(151, null);
    exports.definitionRequestCompletedStatus = localize(152, null);
    exports.updatingIntelliSenseStatus = localize(153, null);
    exports.intelliSenseUpdatedStatus = localize(154, null);
    exports.testLocalizationConstant = localize(155, null);
    exports.disconnectOptionLabel = localize(156, null);
    exports.disconnectOptionDescription = localize(157, null);
    exports.disconnectConfirmationMsg = localize(158, null);
    exports.elapsedBatchTime = localize(159, null);
    exports.noActiveEditorMsg = localize(160, null);
    exports.maximizeLabel = localize(161, null);
    exports.restoreLabel = localize(162, null);
    exports.saveCSVLabel = localize(163, null);
    exports.saveJSONLabel = localize(164, null);
    exports.saveExcelLabel = localize(165, null);
    exports.fileTypeCSVLabel = localize(166, null);
    exports.fileTypeJSONLabel = localize(167, null);
    exports.fileTypeExcelLabel = localize(168, null);
    exports.resultPaneLabel = localize(169, null);
    exports.selectAll = localize(170, null);
    exports.copyLabel = localize(171, null);
    exports.copyWithHeadersLabel = localize(172, null);
    exports.executeQueryLabel = localize(173, null);
    exports.QueryExecutedLabel = localize(174, null);
    exports.messagePaneLabel = localize(175, null);
    exports.messagesTableTimeStampColumn = localize(176, null);
    exports.messagesTableMessageColumn = localize(177, null);
    exports.lineSelectorFormatted = localize(178, null);
    exports.elapsedTimeLabel = localize(179, null);
    exports.msgCannotSaveMultipleSelections = localize(180, null);
    exports.mssqlProviderName = localize(181, null);
    exports.noneProviderName = localize(182, null);
    exports.flavorChooseLanguage = localize(183, null);
    exports.flavorDescriptionMssql = localize(184, null);
    exports.flavorDescriptionNone = localize(185, null);
    exports.msgAddConnection = localize(186, null);
    exports.msgConnect = localize(187, null);
    exports.azureSignIn = localize(188, null);
    exports.azureSignInDescription = localize(189, null);
    exports.azureSignInWithDeviceCode = localize(190, null);
    exports.azureSignInWithDeviceCodeDescription = localize(191, null);
    exports.azureSignInToAzureCloud = localize(192, null);
    exports.azureSignInToAzureCloudDescription = localize(193, null);
    exports.taskStatusWithName = localize(194, null);
    exports.taskStatusWithMessage = localize(195, null);
    exports.taskStatusWithNameAndMessage = localize(196, null);
    exports.failed = localize(197, null);
    exports.succeeded = localize(198, null);
    exports.succeededWithWarning = localize(199, null);
    exports.canceled = localize(200, null);
    exports.inProgress = localize(201, null);
    exports.canceling = localize(202, null);
    exports.notStarted = localize(203, null);
    exports.nodeErrorMessage = localize(204, null);
    exports.deleteCredentialError = localize(205, null);
    exports.msgClearedRecentConnectionsWithErrors = localize(206, null);
    exports.connectProgressNoticationTitle = localize(207, null);
    exports.msgMultipleSelectionModeNotSupported = localize(208, null);
    exports.newColumnWidthPrompt = localize(209, null);
    exports.columnWidthInvalidNumberError = localize(210, null);
    exports.columnWidthMustBePositiveError = localize(211, null);
    exports.objectExplorerNodeRefreshError = localize(212, null);
    exports.showOutputChannelActionButtonText = localize(213, null);
    exports.reloadPrompt = localize(214, null);
    exports.reloadChoice = localize(215, null);
};

//# sourceMappingURL=localizedConstants.js.map
