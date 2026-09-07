CLASS zcl_unit_of_work DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_unit_of_work.

  PRIVATE SECTION.

    "! BAPI_TRANSACTION_COMMIT returns to the caller only once the update has
    "! been written. The next material of a plant wide run reads the
    "! reservation this one created - as open reservations, and as the run that
    "! already served a demand line - so it has to be there by then.
    CONSTANTS c_wait_for_update TYPE bapita-wait VALUE abap_true.

ENDCLASS.


CLASS zcl_unit_of_work IMPLEMENTATION.

  METHOD zif_unit_of_work~commit.

    DATA ls_return TYPE bapiret2.

    " COMMIT WORK is not called directly: the reservation is created by a BAPI,
    " and a BAPI is committed the way SAP says to commit it. A system where
    " that means more than COMMIT WORK then behaves correctly here too.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = c_wait_for_update
      IMPORTING
        return = ls_return.

    IF ls_return-type = 'E' OR ls_return-type = 'A'.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>commit_failed
        mv_message = |{ ls_return-message }| ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_unit_of_work~rollback.

    DATA ls_return TYPE bapiret2.

    " nothing to report: this runs while an error is already on its way up, and
    " the error that got us here is the one worth telling somebody about
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
      IMPORTING
        return = ls_return.

  ENDMETHOD.

ENDCLASS.
