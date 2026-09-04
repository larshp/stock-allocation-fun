REPORT zstock_alloc_move.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr.
PARAMETERS p_prop TYPE zstock_alloc_trf-proposal.
PARAMETERS p_raise AS CHECKBOX.

START-OF-SELECTION.

  TRY.
      DATA(lo_list) = zcl_alloc_move_list=>create_default( ).

      " naming a proposal is answering it; naming none is reading the list.
      " Two screens for two verbs would be two programs to find, and the
      " answer is always given while looking at the list.
      IF p_prop IS INITIAL.
        DATA(lt_line) = lo_list->run(
          iv_werks = p_werks
          iv_matnr = p_matnr ).
      ELSE.
        lt_line = lo_list->answer(
          iv_werks    = p_werks
          iv_proposal = p_prop
          iv_raised   = p_raise ).
      ENDIF.
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
