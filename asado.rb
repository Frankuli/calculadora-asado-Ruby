require 'sinatra'#1.4.8
require 'data_mapper'

DataMapper.setup(:default, 'sqlite:db/development.db')
DataMapper::Logger.new($stdout, :debug)

class Evento
  include DataMapper::Resource
  property :id, Serial
  property :fecha, Date
  property :nombre, String
  property :total, Float #% p/persona

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

get '/index' do
  haml :index
end

get '/productos' do
  haml :productos
end

get '/evento' do
  @eventos = Evento.all
  haml :evento
end

get '/integrantes' do
  haml :integrantes
end

get '/calculo' do
  haml :calculo
end

#create

get '/evento/new' do
  haml :'evento/new'
end
post '/evento/create' do
  evento = Evento.new
  evento.fecha = params[:fecha]
  evento.nombre = params[:nombre]
  evento.save
  p evento
  redirect "/calculo"
end

get '/persona/new' do
  haml :'persona/new'
end
post '/persona/create/:id_evento' do
  evento = Evento.get(params[:id_evento])
  persona = Persona.new
  persona.nombre = params[:nombre]
  evento.personas << persona
  persona.save
  redirect "/evento/detail/#{id_evento}"
end

get '/producto/new' do
  haml :'producto/new'
end
post '/producto/create' do
  producto = Producto.new
  producto.nombre = params[:nombre]
  gasto.save
  redirect "/"
end

get '/gasto/new' do
  haml :'gasto/new'
end
post '/gasto/create/:id_evento/:id_persona/:id_producto' do
  producto = Producto.get(params[:id_producto])
  persona = Persona.get(params[:id_persona])
  evento = Evento.get(params[:id_evento])
  gasto = Gasto.new
  gasto.monto = params[:monto]
  gasto.observacion = params[:observacion]
  producto.gasto << gasto
  producto.save
  persona.gastos << gasto
  persona.save
  evento.gastos << gasto
  evento.save
  redirect "/"
end

#update

get '/evento/update/:id_evento' do 
  @evento_update = Evento.get(params[:id_evento])
  haml :'evento/update'
end 
post '/evento/update/:id_evento' do
  @evento_update = Evento.get(params[:id_evento])
  @evento_update.fecha = params[:fecha]
  @evento_update.nombre = params [:nombre]
  #@evento_update.total = params [:total]
  @evento_update.save
  redirect "/"
end

get '/persona/update/:id_persona' do 
  @persona_update = Persona.get(params[:id_persona])
  haml :'persona/update'
end 
post '/persona/update/:id_persona' do
  @persona_update = Persona.get(params[:id_persona])
  @persona_update.nombre = params[:nombre]
  @persona_update.save
end

get '/producto/update/:id_producto' do 
  @producto_update = Producto.get(params[:id_producto])
  haml :'producto/update'
end 

post '/producto/update/:id_producto' do
  @producto_update = Producto.get(params[:id_producto])
  @producto_update.nombre = params[:nombre]
  @producto_update.save
  redirect '/'
end

#delete

get '/evento/delete/:id_evento' do
  Evento.get(params[:id_evento]).destroy
  redirect "/evento"
end

get '/persona/delete/:id_persona' do
  Persona.get(params[:id_piersona0]).destroy
  redirect "/"
end

get '/producto/delete/:id_producto' do
  Producto.get(params[:id_producto]).destroy
  redirect "/"
end

get '/gasto/delete/:id_gasto' do
  Gasto.get(params[:id_gasto]).destroy
  redirect "/"
end

#list

get '/evento/detail/:id_evento' do
  @un_evento = Evento.get(params[:id_evento])
  haml :'evento/detail' 
end

get '/persona_detail/:id_persona' do
  @una_persona = Persona.get(params[:id_persona])
  haml :'persona/detail'
end

