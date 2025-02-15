// Function to exchange Google Token for AWS Cognito credentials
function credentialExchange(googleToken) {
    AWS.config.region = 'ap-south-1';  // Set your AWS region

    AWS.config.credentials = new AWS.CognitoIdentityCredentials({
        IdentityPoolId: 'ap-south-1:f950a416-5f93-4bf3-9126-8a22348aa47c',  // Replace with your Cognito Identity Pool ID
        Logins: {
            'accounts.google.com': googleToken
        }
    });

    AWS.config.credentials.get(function(err) {
        if (!err) {
            console.log("Exchanged to Cognito Identity ID: " + AWS.config.credentials.identityId);
            accessS3Bucket();  // Fetch images from S3 after authentication
        } else {
            document.getElementById('imageContainer').innerHTML = "<b>Authorization failed!</b>";
            console.log("ERROR: " + err);
        }
    });
}

// Function to fetch images from S3 bucket
function accessS3Bucket() {
    console.log("Fetching Images from S3...");
    
    var s3 = new AWS.S3();
    var params = {
        Bucket: "patchesprivatebucket-af507e1d",  // Replace with your S3 bucket name
        Prefix: "."  // Folder where images are stored
    };

    s3.listObjectsV2(params, function(err, data) {
        if (err) {
            console.log("Error accessing S3: ", err);
        } else {
            var imageContainer = document.getElementById("imageContainer");
            imageContainer.innerHTML = "";

            data.Contents.forEach(function (image) {
                var imgElement = document.createElement("img");
                imgElement.src = "https://" + params.Bucket + ".s3.amazonaws.com/" + image.Key;
                imgElement.style.width = "200px";
                imgElement.style.margin = "10px";
                imageContainer.appendChild(imgElement);
            });

            console.log("Images loaded successfully!");
        }
    });
}
