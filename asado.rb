require 'sinatra'#1.4.8
require 'data_mapper'

DataMapper.setup(:default, 'sqlite:db/development.db')
DataMapper::Logger.new($stdout, :debug)

class Evento
  include DataMapper::Resource
  property :id, Serial
  property :fecha, Date
  property :nombre, String
  property :total, Integer #% p/persona

  has n, :personas 
  has n, :gastos
end

class Persona
  include DataMapper::Resource
  property :id, Serial
  property :nombre, String
  
  belongs_to :evento
  has n, :gastos
end

class Producto 
  include DataMapper::Resource
  property :id, Serial
  property :nombre, String

  belongs_to :gasto #opc
end

class Gasto
  include DataMapper::Resource
  property :id, Serial
  property :monto, Integer #total de lo gastado
  property :observacion, String

  has 1, :producto
  belongs_to :persona
  belongs_to :evento
end

Evento.auto_upgrade!
Persona.auto_upgrade!
Producto.auto_upgrade!
Gasto.auto_upgrade!

DataMapper.finalize

get '/' do
  haml :index
end

#create

get '/evento_new' do
  haml :'evento/new'
end
post '/evento_create' do
  evento = Evento.new
  evento.fecha = params[:fecha]
  evento.nombre = params [:nombre]
  #evento.total = params [:total]
  evento.save
  redirect
end

get '/persona_new' do
  haml :'persona/new'
end
post '/persona_create/:id_evento' do
  evento = Evento.get(params[:id_evento])
  persona = Persona.new
  persona.nombre = params[:nombre]
  evento.personas << persona
  persona.save
  redirect "/evento_detail/#{id_evento}"
end

get '/producto_new' do
  haml :'producto/new'
end
post '/producto_create/:id_gasto' do
  gasto = Gasto.get(params[:id_gasto])
  producto = Producto.new
  producto.nombre = params[:nombre]
  gasto.producto << producto
  gasto.save
  redirect "/"
end

get '/gasto_new' do
  haml :'gasto/new'
end
post '/gasto_create/:id_evento/:id_persona' do
  persona = Persona.get(params[:id_persona])
  evento = Evento.get(params[:id_evento])
  gasto = Gasto.new
  gasto.monto = params[:monto]
  gasto.observacion = params [:observacion]
  persona.gastos << gasto
  persona.save
  evento.gastos << gasto
  evento.save
  redirect "/"
end

#update

get '/evento_update/:id_evento' do 
  @evento_update = Evento.get(params[:id_evento])
  haml :'evento/update'
end 
post '/evento_update/:id_evento' do
  @evento_update = Evento.get(params[:id_evento])
  @evento_update.fecha = params[:fecha]
  @evento_update.nombre = params [:nombre]
  #@evento_update.total = params [:total]
  @evento_update.save
  redirect "/"
end

get '/persona_update/:id_persona' do 
  @persona_update = Persona.get(params[:id_persona])
  haml :'persona/update'
end 
post '/persona_update/:id_persona' do
  @persona_update = Persona.get(params[:id_persona])
  @persona_update.nombre = params[:nombre]
  @persona_update.save
end

get '/producto_update/:id_producto' do 
  @producto_update = Producto.get(params[:id_producto])
  haml :'producto/update'
end 

post '/producto_update/:id_producto' do
  @producto_update = Producto.get(params[:id_producto])
  @producto_update.nombre = params[:nombre]
  @producto_update.save
  redirect '/'
end

#delete

get '/evento_delete/:id_evento' do
  Evento.get(params[:id_evento]).destroy
  redirect "/"
end

get '/persona_delete/:id_persona' do
  Persona.get(params[:id_piersona0]).destroy
  redirect "/"
end

get '/producto_delete/:id_producto' do
  Producto.get(params[:id_producto]).destroy
  redirect "/"
end

get '/gasto_delete/:id_gasto' do
  Gasto.get(params[:id_gasto]).destroy
  redirect "/"
end

#list

get '/evento_detail/:id_evento' do
  @un_evento = Evento.get(params[:id_evento])
  haml :'evento/detail' 
end

get '/persona_detail/:id_persona' do
  @una_persona = Persona.get(params[:id_persona])
  haml :'persona/detail'
end

