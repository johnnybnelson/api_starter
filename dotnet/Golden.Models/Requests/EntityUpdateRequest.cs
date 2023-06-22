﻿using Golden.Models.Interfaces;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace Golden.Models.Requests
{
    public class EntityUpdateRequest : IModelIdentifier
    {
        //The Required Attribute is not required  b/c IModelIdentifier takes care of it
        public int Id { get; set; }
    }
}
