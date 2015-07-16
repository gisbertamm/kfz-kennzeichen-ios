//
//  SQLiteStatusCode.swift
//  SwiftSQLite
//
//  Created by Chris on 4/07/2014.
//  Copyright (c) 2014 Victory One Media Pty Ltd. All rights reserved.
//

import Foundation

enum SQLiteStatusCode : CInt {
    case Ok = 0                         /* Successful result */
    /* beginning-of-error-codes */
    case Error = 1                      /* SQL error or missing database */
    case InternalLogicError = 2         /* Internal logic error in SQLite */
    case AccessPermissionDenied = 3     /* Access permission denied */
    case Abort = 4                      /* Callback routine requested an abort */
    case Busy = 5                       /* The database file is locked */
    case Locked = 6                     /* A table in the database is locked */
    case NoMemory = 7                   /* A malloc() failed */
    case ReadOnly = 8                   /* Attempt to write a readonly database */
    case Interrupt = 9                  /* Operation terminated by sqlite3_interrupt()*/
    case IOError = 10                   /* Some kind of disk I/O error occurred */
    case Corrupt = 11                   /* The database disk image is malformed */
    case NotFound = 12                  /* Unknown opcode in sqlite3_file_control() */
    case Full = 13                      /* Insertion failed because database is full */
    case CantOpen = 14                  /* Unable to open the database file */
    case Protocol = 15                  /* Database lock protocol error */
    case Empty = 16                     /* Database is empty */
    case Schema = 17                    /* The database schema changed */
    case TooBig = 18                    /* String or BLOB exceeds size limit */
    case Constraint = 19                /* Abort due to constraint violation */
    case Mismatch = 20                  /* Data type mismatch */
    case Misuse = 21                    /* Library used incorrectly */
    case NoLFS = 22                     /* Uses OS features not supported on host */
    case AuthDeniedUTH = 23             /* Authorization denied */
    case Format = 24                    /* Auxiliary database format error */
    case Range = 25                     /* 2nd parameter to sqlite3_bind out of range */
    case NotADatabase = 26              /* File opened that is not a database file */
    case Row = 100                      /* sqlite3_step() has another row ready */
    case Done = 101                     /* sqlite3_step() has finished executing */
}
