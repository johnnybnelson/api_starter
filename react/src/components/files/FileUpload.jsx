import React, { useState, useEffect } from "react";
import * as filesService from "../../services/filesService";
import Carousel from 'react-bootstrap/Carousel';


function FileUpload() {



    //set states
    //
    const [selectedFile, setSelectedFile] = useState();
    const [isFilePicked, setIsFilePicked] = useState(false);
    const [fileCollection, setFileList] = useState({
        files: [],
        fileData: []
    });

    //when the file is selected
    //
    const changeHandler = (event) => {
        //set states
        setSelectedFile(() => { return event.target.files[0] });
        setIsFilePicked(() => { return true });
    };

    //push the new file onto the file list array
    //
    const addSelectionToImageList = (newFile) => {

        //change the state by adding the newly-uploaded file to the 
        //file list array
        //
        setFileList((prevFileCollection) => {

            let newObj = JSON.parse(JSON.stringify(prevFileCollection));

            newObj.files.push(newFile);

            return newObj;

        })
    }

    //when the submit button is clicked
    //
    const submitFile = () => {

        const formData = new FormData();
        formData.append('File', selectedFile);

        filesService
            .uploadFile(formData)
            .then(uploadSuccess)
            .catch(uploadError);

    }

    //mapping array
    //


    const buildAnchors = (link) => {
        return (<Carousel.Item style={{ width: "600px" }}>
            <img
                className="d-block w-100"
                src={link}
                alt="Slide"
                style={{ objectFit: "contain" }}
            />
        </Carousel.Item>);
    }

    var uploadSuccess = (response) => {
        console.log("success", response);
        setIsFilePicked(true);
        //addSelectionToImageList(response.data.items[0])
        addSelectionToImageList(response.data);
    }

    //failure
    var uploadError = (err) => {
        console.log("failure", err);
    }

    // this is invoked following successful mount
    // 
    useEffect(() => {
        setSelectedFile(() => { return "" });
        setIsFilePicked(() => { return false });
    }, [fileCollection.files]
    );

    return (
        <div className="row">
            <input type="file" name="file" onChange={changeHandler} />
            {isFilePicked ? (
                <div>
                    <h5>File Information</h5>
                    <p>Filetype: {selectedFile.type}</p>
                    <p>Size in bytes: {selectedFile.size}</p>
                    <p>
                        lastModifiedDate:{' '}
                        {selectedFile.lastModifiedDate.toLocaleDateString()}
                    </p>
                    <h5>File List</h5>
                </div>
            ) : (
                <p>Select a file to show details</p>
            )}

            <div>
                <button onClick={submitFile}>Submit</button>

                <div className="col-5">
                    <hr />
                    <Carousel controls={fileCollection.files.length > 0 ? true : false}>
                        {fileCollection.files.map(buildAnchors)}
                    </Carousel>
                </div>
            </div>
        </div>
    );
}
export default FileUpload;