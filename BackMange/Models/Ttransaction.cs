﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace BackMange.Models;

public partial class Ttransaction
{
    public int TransactionId { get; set; }

    public int TaskId { get; set; }

    public int PostUserId { get; set; }

    public int WorkUserId { get; set; }

    public int Amount { get; set; }

    public string Status { get; set; }

    public DateTime StartTime { get; set; }

    public DateTime? FinishTime { get; set; }

    public int? Rating { get; set; }

    public string Review { get; set; }

    public virtual TUser PostUser { get; set; }

    public virtual TTask Task { get; set; }

    public virtual TUser WorkUser { get; set; }
}