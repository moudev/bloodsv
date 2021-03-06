class ContactsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_contact, only: %i[show edit update destroy]

  # GET /contacts
  # GET /contacts.json
  def index
    params[:donors] ? load_donors : load_contacts
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new(kind: :patient)
  end

  def new_donor
    @contact = Contact.new(kind: :donor)
    render :new
  end

  # GET /contacts/1/edit
  def edit
    authorize @contact
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)
    @contact.user = current_user

    respond_to do |format|
      if @contact.save
        format.html { redirect_to @contact, notice: 'Información guardada exitosamente' }
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    authorize @contact

    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, notice: 'Información actualizada exitosamente' }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    authorize @contact

    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Información eliminada exitosamente' }
      format.json { head :no_content }
    end
  end

  protected

  def load_contacts
    @contacts ||= load_all_contacts.by_patient
  end

  def load_donors
    @contacts ||= load_all_contacts.by_donor
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_contact
    @contact = Contact.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def contact_params
    params.require(:contact).permit(:blood_type, :hospital_id, :first_name, :last_name, :mobile, :status, :details,
                                    :email, :kind, :background)
  end

  def load_all_contacts
    (user_signed_in? ? Contact.by_user(current_user) : Contact.by_active).order('updated_at DESC')
  end
end
