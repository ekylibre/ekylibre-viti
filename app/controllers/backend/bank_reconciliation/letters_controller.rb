module Backend
  module BankReconciliation
    # Handles bank reconciliation lettering.
    class LettersController < Backend::BaseController
      def create
        return unless find_cash

        bank_items     = BankStatementItem.where(id: params[:bank_statement_items])
        journal_items  = JournalEntryItem.where(id: params[:journal_entry_items])

        new_letter = @cash.letter_items(bank_items, journal_items)
        return head(:bad_request) unless new_letter

        respond_to do |format|
          format.json {  render json: { letter: new_letter } }
        end
      end

      def destroy
        return unless request.xhr? && find_cash

        letter = params[:letter]
        account_id = @cash.account_id

        bsi = BankStatementItem.joins(cash: :suspense_account).where("letter = '#{letter}' AND accounts.id = #{account_id}")
        jei = bsi.first.associated_journal_entry_items

        bsi.update_all(letter: nil)
        jei.update_all(bank_statement_letter: nil, bank_statement_id: nil, letter: nil)

        respond_to do |format|
          format.json {  render json: { letter: letter } }
        end
      end

      private

      def find_cash
        @cash = Cash.find_by(id: params[:cash_id])
        @cash || (head(:bad_request) && nil)
      end
    end
  end
end
