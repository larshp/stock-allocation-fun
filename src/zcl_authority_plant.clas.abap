CLASS zcl_authority_plant DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

  PRIVATE SECTION.

    "! Changing material stock at plant level, the same object the standard
    "! inventory transactions check.
    CONSTANTS c_activity_change TYPE activ_auth VALUE '02'.

ENDCLASS.


CLASS zcl_authority_plant IMPLEMENTATION.

  METHOD zif_allocation_authority~check_plant.

    AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
      ID 'ACTVT' FIELD c_activity_change
      ID 'WERKS' FIELD iv_werks.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid   = zcx_allocation=>not_authorised
        mv_werks = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
