CLASS ltcl_summary DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA summarizer TYPE REF TO zcl_stock_alloc_summary.
    DATA allocations TYPE zif_stock_alloc_types=>ty_allocations.
    METHODS setup.
    METHODS totals_and_shortage_date FOR TESTING RAISING zcx_stock_alloc.
    METHODS keeps_units_and_keys_separate FOR TESTING RAISING zcx_stock_alloc.
    METHODS empty_and_full_only FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_invalid_allocations FOR TESTING.
    METHODS rejects_quantity_overflow FOR TESTING.
    METHODS supports_quantity_boundary FOR TESTING RAISING zcx_stock_alloc.
ENDCLASS.

CLASS ltcl_summary IMPLEMENTATION.
  METHOD setup.
    summarizer = NEW #( ).
    allocations = VALUE #(
      ( request_id = 'FULL' material = 'MAT1' plant = '1000' storage = '0001' unit = 'EA'
        requested = '0.100' allocated = '0.100' required_date = '20260901' )
      ( request_id = 'PART' material = 'MAT1' plant = '1000' storage = '0001' unit = 'EA'
        requested = '0.300' allocated = '0.200' shortage = '0.100' required_date = '20260910' )
      ( request_id = 'ZERO' material = 'MAT1' plant = '1000' storage = '0001' unit = 'EA'
        requested = '0.400' shortage = '0.400' required_date = '20260906' ) ).
  ENDMETHOD.

  METHOD totals_and_shortage_date.
    DATA(result) = summarizer->summarize( allocations ).
    cl_abap_unit_assert=>assert_equals( act = lines( result )
                                      exp   = 1 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-requested
                                      exp   = '0.800' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                      exp   = '0.300' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-shortage
                                      exp   = '0.500' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-request_count
                                      exp   = 3 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-full_count
                                      exp   = 1 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-partial_count
                                      exp   = 1 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-unfilled_count
                                      exp   = 1 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-first_shortage_date
                                      exp   = '20260906' ).
    SORT allocations BY request_id DESCENDING.
    cl_abap_unit_assert=>assert_equals( act = summarizer->summarize( allocations )
                                      exp   = result ).
  ENDMETHOD.

  METHOD keeps_units_and_keys_separate.
    allocations[ 1 ]-material = 'MAT2'.
    allocations[ 2 ]-plant = '2000'.
    DATA(extra) = allocations[ 3 ].
    extra-request_id = 'STORAGE'.
    extra-storage = '0002'.
    APPEND extra TO allocations.
    extra-request_id = 'UNIT'.
    extra-storage = '0001'.
    extra-unit = 'KG'.
    APPEND extra TO allocations.
    DATA(result) = summarizer->summarize( allocations ).
    cl_abap_unit_assert=>assert_equals( act = lines( result )
                                      exp   = 5 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-unit
                                      exp   = 'EA' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-unit
                                      exp   = 'KG' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 3 ]-storage
                                      exp   = '0002' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 4 ]-plant
                                      exp   = '2000' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 5 ]-material
                                      exp   = 'MAT2' ).
  ENDMETHOD.

  METHOD empty_and_full_only.
    DELETE allocations WHERE request_id <> 'FULL'.
    DATA(result) = summarizer->summarize( allocations ).
    cl_abap_unit_assert=>assert_initial( result[ 1 ]-first_shortage_date ).
    cl_abap_unit_assert=>assert_initial( result[ 1 ]-shortage ).
    cl_abap_unit_assert=>assert_initial( summarizer->summarize( VALUE #( ) ) ).
  ENDMETHOD.

  METHOD rejects_invalid_allocations.
    allocations[ 2 ]-shortage = '0.200'.
    TRY.
        summarizer->summarize( allocations ).
        cl_abap_unit_assert=>fail( 'Inconsistent quantities summarized' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
    allocations[ 2 ]-shortage = '0.100'.
    APPEND allocations[ 1 ] TO allocations.
    TRY.
        summarizer->summarize( allocations ).
        cl_abap_unit_assert=>fail( 'Duplicate allocation counted twice' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_quantity_overflow.
    allocations[ 1 ]-requested = '9999999999.999'.
    allocations[ 1 ]-allocated = '9999999999.999'.
    TRY.
        summarizer->summarize( allocations ).
        cl_abap_unit_assert=>fail( 'Summary quantity overflow accepted' ).
      CATCH zcx_stock_alloc INTO DATA(error).
        cl_abap_unit_assert=>assert_equals( act = error->reason
                                          exp   = 'Grouped requested quantity exceeds the supported quantity range' ).
    ENDTRY.
  ENDMETHOD.

  METHOD supports_quantity_boundary.
    DELETE allocations WHERE request_id = 'ZERO'.
    allocations[ 1 ]-requested = '9999999999.699'.
    allocations[ 1 ]-allocated = '9999999999.699'.
    DATA(result) = summarizer->summarize( allocations ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-requested
                                      exp   = '9999999999.999' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                      exp   = '9999999999.899' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-shortage
                                      exp   = '0.100' ).
  ENDMETHOD.
ENDCLASS.
