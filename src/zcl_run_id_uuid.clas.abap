CLASS zcl_run_id_uuid DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_run_id_supplier.

ENDCLASS.


CLASS zcl_run_id_uuid IMPLEMENTATION.

  METHOD zif_run_id_supplier~next.

    TRY.
        rv_run_id = cl_system_uuid=>create_uuid_c22_static( ).
      CATCH cx_uuid_error INTO DATA(lx_error).
        RAISE EXCEPTION NEW zcx_allocation( previous = lx_error ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
