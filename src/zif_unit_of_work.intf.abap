INTERFACE zif_unit_of_work PUBLIC.

  "! <p class="shorttext synchronized">Make everything written since the last one durable</p>
  "!
  "! The allocation writes its own table and asks a BAPI to create a
  "! reservation; neither is on the database until something commits. This is
  "! that something, and it waits for the update to finish, because the next
  "! run reads what this one wrote.
  "!
  "! @raising zcx_allocation | <p class="shorttext synchronized">The work could not be committed</p>
  METHODS commit
    RAISING
      zcx_allocation.

  "! <p class="shorttext synchronized">Throw away everything written since the last commit</p>
  "!
  "! For a run that failed half way: what it managed to write says something
  "! that is not true, and leaving it for the next run to trip over is worse
  "! than having no answer at all.
  METHODS rollback.

ENDINTERFACE.
