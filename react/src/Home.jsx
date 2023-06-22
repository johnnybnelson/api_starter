import React, { useEffect } from "react";

function Home(props) {



  // this is invoked following successful mount
  // 
  useEffect(() => {
    console.log("App mounted!", props);
    //props.pingUserStatus();
  }, []
  );


  return (
    <React.Fragment>
      <div className="container">
        <div className="mb-4 bg-light">
          <div className="container-fluid">
            <h1>Home</h1>
          </div>
        </div>

      </div>
    </React.Fragment>
  );
}

export default Home;
