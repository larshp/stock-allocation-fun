CLASS zcl_alloc_auth DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_object TYPE c LENGTH 10.
    TYPES ty_actvt  TYPE c LENGTH 2.

    TYPES: BEGIN OF ty_grant,
             object TYPE ty_object,
             actvt  TYPE ty_actvt,
           END OF ty_grant.
    TYPES ty_grant_tt TYPE STANDARD TABLE OF ty_grant WITH DEFAULT KEY.

    METHODS constructor
      IMPORTING
        it_grants TYPE ty_grant_tt.

    METHODS is_authorized
      IMPORTING
        iv_object            TYPE ty_object
        iv_actvt             TYPE ty_actvt
      RETURNING
        VALUE(rv_authorized) TYPE abap_bool.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    DATA mt_grants TYPE ty_grant_tt.

ENDCLASS.


CLASS zcl_alloc_auth IMPLEMENTATION.

  METHOD constructor.
    mt_grants = it_grants.
  ENDMETHOD.

  METHOD is_authorized.
    DATA ls_grant TYPE ty_grant.

    LOOP AT mt_grants INTO ls_grant.
      IF ls_grant-object = iv_object.
        IF ls_grant-actvt = iv_actvt OR ls_grant-actvt = '*'.
          rv_authorized = abap_true.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_grants ).
  ENDMETHOD.

ENDCLASS.
