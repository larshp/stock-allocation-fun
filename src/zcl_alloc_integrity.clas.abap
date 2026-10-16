CLASS zcl_alloc_integrity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_report,
             expected   TYPE i,
             actual     TYPE i,
             is_intact  TYPE abap_bool,
             line_count TYPE i,
           END OF ty_report.

    METHODS check
      IMPORTING
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
        iv_expected      TYPE i
      RETURNING
        VALUE(rs_report) TYPE ty_report.

ENDCLASS.


CLASS zcl_alloc_integrity IMPLEMENTATION.

  METHOD check.
    DATA lo_checksum TYPE REF TO zcl_alloc_checksum.

    lo_checksum = NEW zcl_alloc_checksum( ).

    rs_report-expected = iv_expected.
    rs_report-actual = lo_checksum->of_result( it_result ).
    rs_report-line_count = lines( it_result ).

    IF rs_report-actual = rs_report-expected.
      rs_report-is_intact = abap_true.
    ELSE.
      rs_report-is_intact = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
