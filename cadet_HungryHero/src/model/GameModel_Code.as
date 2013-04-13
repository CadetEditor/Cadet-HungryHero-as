package model
{
	import cadet.components.processes.SoundProcess;
	import cadet.components.sounds.SoundComponent;
	import cadet.core.CadetScene;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.particles.PDParticleSystemComponent;
	import cadet2D.components.processes.WorldBounds2D;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.skins.MovieClipSkin;
	import cadet2D.components.textures.TextureAtlasComponent;
	import cadet2D.components.textures.TextureComponent;
	import cadet2D.components.transforms.Transform2D;
	
	import core.app.managers.ResourceManager;
	
	import hungryHero.components.behaviours.HeroBehaviour;
	import hungryHero.components.behaviours.MagnetBehaviour;
	import hungryHero.components.behaviours.MoveBehaviour;
	import hungryHero.components.behaviours.ObstacleBehaviour;
	import hungryHero.components.behaviours.ParallaxBehaviour;
	import hungryHero.components.behaviours.ShakeBehaviour;
	import hungryHero.components.behaviours.SpeedUpBehaviour;
	import hungryHero.components.processes.BackgroundsProcess;
	import hungryHero.components.processes.EatParticlesProcess;
	import hungryHero.components.processes.GlobalsProcess;
	import hungryHero.components.processes.ItemsProcess;
	import hungryHero.components.processes.ObstaclesProcess;
	import hungryHero.components.processes.WindParticlesProcess;
	
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;

	// This class constructs a CadetEngine 2D scene using the CadetEngine API
	public class GameModel_Code implements IGameModel
	{
		private var _cadetScene				:CadetScene;
		private var _renderer				:Renderer2D;
		private var _resourceManager		:ResourceManager;
		
		// ASSETS
		private var bgLayerURL				:String = "hungryHero/graphics/bgLayer1.jpg";
		private var spriteSheetURL			:String = "hungryHero/graphics/mySpritesheet.png";
		private var spriteSheetXMLURL		:String = "hungryHero/graphics/mySpritesheet.xml";
		private var particleCoffeeXMLURL	:String = "hungryHero/particles/particleCoffee.pex";
		private var particleMushroomXMLURL	:String = "hungryHero/particles/particleMushroom.pex";
		
		// SOUNDS
		private var eatSoundURL				:String = "hungryHero/sounds/eat.mp3";
		private var coffeeSoundURL			:String = "hungryHero/sounds/coffee.mp3";
		private var mushroomSoundURL		:String = "hungryHero/sounds/mushroom.mp3";
		private var bgMusicURL				:String = "hungryHero/sounds/bgGame.mp3";
		private var hitSoundURL				:String = "hungryHero/sounds/hit.mp3";
		private var hurtSoundURL			:String = "hungryHero/sounds/hurt.mp3";
		
		private var _allSprites				:TextureComponent;
		private var _allSpritesAtlas		:TextureAtlasComponent;
		
		private var _worldBounds			:WorldBounds2D;
		
		private var _parallaxSpeed			:int = -15;
		
		private var _skySkin				:ImageSkin;
		private var _hillsSkin				:ImageSkin;
		private var _midgroundSkin			:ImageSkin;
		private var _foregroundSkin			:ImageSkin;
		
		private var _heroSkin				:MovieClipSkin;
		private var _heroTransform2D		:Transform2D;
		
		private var _parent					:starling.display.DisplayObjectContainer;
		
		private var _eatSound				:SoundComponent;
		private var _mushroomSound			:SoundComponent;
		private var _coffeeSound			:SoundComponent;
		private var _musicSound				:SoundComponent;
		private var _hitSound				:SoundComponent;
		private var _hurtSound				:SoundComponent;
		
		private var _globals				:GlobalsProcess;
		private var _soundProcess			:SoundProcess;
		
		private var _heroStartX				:Number;
		private var _heroStartY				:Number;
		
		private var _shakeBehaviour			:ShakeBehaviour;
		
		private var _coffeeParticles		:PDParticleSystemComponent;
		private var _mushroomParticles		:PDParticleSystemComponent;
		
		private var _muted					:Boolean;
		
		public function GameModel_Code( resourceManager:ResourceManager )
		{
			_resourceManager 	= resourceManager;
			
			// Create a CadetScene
			_cadetScene = new CadetScene();
			
			// Add a 2D Renderer to the scene
			_renderer = new Renderer2D(true);
			_cadetScene.children.addItem(_renderer);
			
			// Add the main texture to the scene
			_allSprites = new TextureComponent("All Sprites");
			_resourceManager.bindResource(spriteSheetURL, _allSprites, "bitmapData");
			_cadetScene.children.addItem(_allSprites);
			
			// Add the main texture atlas to the scene
			_allSpritesAtlas = new TextureAtlasComponent("All Sprites Atlas");
			_allSpritesAtlas.texture = _allSprites;
			_resourceManager.bindResource(spriteSheetXMLURL, _allSpritesAtlas, "xml");
			_cadetScene.children.addItem(_allSpritesAtlas);
			
			// Add the Global variables
			_globals = new GlobalsProcess();
			_cadetScene.children.addItem(_globals);
			
			// Define WorldBounds
			_worldBounds = new WorldBounds2D();
			_cadetScene.children.addItem(_worldBounds);
			_worldBounds.top 	= 100;
			_worldBounds.left 	= 0;
			_worldBounds.right 	= 1024;
			_worldBounds.bottom 	= 768 - 250;
			
			// Add ShakeBehaviour
			_shakeBehaviour = new ShakeBehaviour();
			_cadetScene.children.addItem(_shakeBehaviour);
			_shakeBehaviour.target = _renderer;
			
			addSounds();
			addBackgrounds();
			addParticles();
			addHero();
			addItems();
			addObstacles();	
		}
	
		public function init(parent:starling.display.DisplayObjectContainer):void
		{
			_parent 			= parent;
			
			_renderer.viewportWidth = _parent.stage.stageWidth;
			_renderer.viewportHeight = _parent.stage.stageHeight;
			_renderer.enableToExisting(_parent);
			
			_globals.paused = true;
			
			_parent.addEventListener( starling.events.Event.ENTER_FRAME, enterFrameHandler );
		}
		
		public function reset():void
		{
			_globals.reset();
			_globals.paused = true;
			
			_heroTransform2D.x = _heroStartX;
			_heroTransform2D.y = _heroStartY;
			
			_shakeBehaviour.shake = 0;
		}
		
		public function get muted():Boolean
		{
			return _muted;
		}
		public function set muted( value:Boolean ):void
		{
			_muted = value;
			if ( _soundProcess ) {
				_soundProcess.muted = _muted;
			}
		}
		
		public function dispose():void
		{
			_cadetScene.dispose();
			_parent.removeEventListener( starling.events.Event.ENTER_FRAME, enterFrameHandler );	
		}
		
		private function enterFrameHandler( event:starling.events.Event ):void
		{
			_cadetScene.step();
		}
		
		public function get cadetScene():CadetScene
		{
			return _cadetScene;
		}
		
		public function set cadetScene( value:CadetScene ):void
		{
			_cadetScene = value;
		}
		
		private function addSounds():void
		{
			_musicSound = new SoundComponent("Music Sound");
			_musicSound.loops = 999;
			_resourceManager.bindResource(bgMusicURL, _musicSound, "asset");			
			
			_eatSound = new SoundComponent("Eat Sound");
			_resourceManager.bindResource(eatSoundURL, _eatSound, "asset");
			
			_mushroomSound = new SoundComponent("Collect Mushroom Sound");
			_resourceManager.bindResource(mushroomSoundURL, _mushroomSound, "asset");
			
			_coffeeSound = new SoundComponent("Collect Coffee Sound");
			_resourceManager.bindResource(coffeeSoundURL, _coffeeSound, "asset");
			
			_hitSound = new SoundComponent("Hit Sound");
			_resourceManager.bindResource(hitSoundURL, _hitSound, "asset");
			
			_hurtSound = new SoundComponent("Hurt Sound");
			_resourceManager.bindResource(hurtSoundURL, _hurtSound, "asset");
			
			_soundProcess = new SoundProcess();
			_cadetScene.children.addItem(_soundProcess);
			_soundProcess.music = _musicSound;
		}
		
		private function addBackgrounds():void
		{
			// Add the sky texture to the scene
			var skyTexture:TextureComponent = new TextureComponent("Sky Texture");
			// set skyTexture.bitmapData via the ResourceManager
			_resourceManager.bindResource(bgLayerURL, skyTexture, "bitmapData");
			_cadetScene.children.addItem(skyTexture);
			
			var backgroundsProcess:BackgroundsProcess = new BackgroundsProcess();
			_cadetScene.children.addItem(backgroundsProcess);
			
			var parallax:ParallaxBehaviour;
			
			// Add the sky to the scene
			var sky:Entity = new Entity("Sky");
			_cadetScene.children.addItem(sky);
			// Add an ImageSkin to the sky Entity
			_skySkin = new ImageSkin("Sky Skin");
			sky.children.addItem(_skySkin);
			_skySkin.texture = skyTexture;
			// Add a ParallaxBehaviour to the sky Entity
			parallax = new ParallaxBehaviour();
			parallax.depth = 0.1;
			parallax.speed = _parallaxSpeed;
			_skySkin.parentComponent.children.addItem(parallax);
			
			// Add the background hills to the scene
			var hills:Entity = new Entity("Hills");
			_cadetScene.children.addItem(hills);
			// Add an ImageSkin to the hills Entity
			_hillsSkin = new ImageSkin("Hills Skin");
			hills.children.addItem(_hillsSkin);
			_hillsSkin.textureAtlas = _allSpritesAtlas;
			_hillsSkin.texturesPrefix = "bgLayer2";
			_hillsSkin.y = 440;
			// Add a ParallaxBehaviour to the hills Entity
			parallax = new ParallaxBehaviour();
			parallax.depth = 0.3;
			parallax.speed = _parallaxSpeed;
			_hillsSkin.parentComponent.children.addItem(parallax);
			
			// Add the midground to the scene
			var midground:Entity = new Entity("Midground");
			_cadetScene.children.addItem(midground);
			// Add an ImageSkin to the midground Entity
			_midgroundSkin = new ImageSkin("Midground Skin");
			midground.children.addItem(_midgroundSkin);	
			_midgroundSkin.textureAtlas = _allSpritesAtlas;
			_midgroundSkin.texturesPrefix = "bgLayer3";	
			_midgroundSkin.y = 510;
			// Add a ParallaxBehaviour to the midground Entity
			parallax = new ParallaxBehaviour();
			parallax.depth = 0.6;
			parallax.speed = _parallaxSpeed;
			_midgroundSkin.parentComponent.children.addItem(parallax);
			
			// Add the foreground to the scene
			var foreground:Entity = new Entity("Foreground");
			_cadetScene.children.addItem(foreground);
			// Add an ImageSkin to the foreground Entity
			_foregroundSkin = new ImageSkin("Foreground Skin");
			foreground.children.addItem(_foregroundSkin);
			_foregroundSkin.textureAtlas = _allSpritesAtlas;
			_foregroundSkin.texturesPrefix = "bgLayer4";	
			_foregroundSkin.y = 600;
			// Add a ParallaxBehaviour to the foreground Entity
			parallax = new ParallaxBehaviour();
			parallax.depth = 1;
			parallax.speed = _parallaxSpeed;
			_foregroundSkin.parentComponent.children.addItem(parallax);
		}
		
		private function addHero():void
		{
			_heroStartX = -200;
			_heroStartY = 300;
			
			// Add Hero entity to the scene
			var hero:Entity = new Entity("Hero");
			_cadetScene.children.addItem(hero);
			// Add a 2D transform
			_heroTransform2D = new Transform2D();
			_heroTransform2D.x = _heroStartX;
			_heroTransform2D.y = _heroStartY;
			hero.children.addItem(_heroTransform2D);
			// Add an animatable MovieClipSkin
			_heroSkin = new MovieClipSkin("Hero Skin");
			_heroSkin.textureAtlas = _allSpritesAtlas;
			_heroSkin.texturesPrefix = "fly_";
			_heroSkin.loop = true;
			hero.children.addItem(_heroSkin);
			// Add the HeroBehaviour
			var heroBehaviour:HeroBehaviour = new HeroBehaviour();
			hero.children.addItem(heroBehaviour);
		}
		
		private function addItems():void
		{
			// Add the Items Entity
			var itemsEntity:Entity = new Entity("Items");
			_cadetScene.children.addItem(itemsEntity);
			
			// Place items to the right of the stage
			var startXpos:Number = _worldBounds.right + 20;
			var startYpos:Number = 0;
			
			var xpos:Number = startXpos;
			var ypos:Number = startYpos;
			
			for ( var i:uint = 0; i < 5; i ++ ) {
				// Add an ImageSkin to the itemsEntity
				var imageSkin:ImageSkin = new ImageSkin("Item "+(i+1));
				imageSkin.x = xpos;
				imageSkin.textureAtlas = _allSpritesAtlas;
				imageSkin.texturesPrefix = "item"+(i+1);
				itemsEntity.children.addItem(imageSkin);
				// Place all of the items in a line so it looks neat in the editor
				xpos += 40;
			}
			
			// Add the Powerups Entity
			var powerupsEntity:Entity = new Entity("Powerups");
			_cadetScene.children.addItem(powerupsEntity);
			
			// Reset position values
			xpos = startXpos;
			ypos = startYpos + 50;
			
			// Add Coffee powerup
			var powerup:Entity = new Entity("Coffee");
			powerupsEntity.children.addItem(powerup);
			imageSkin = new ImageSkin("Coffee Skin");
			powerup.children.addItem(imageSkin);
			imageSkin.x = xpos;
			imageSkin.y = ypos;
			imageSkin.textureAtlas = _allSpritesAtlas;
			imageSkin.texturesPrefix = "item6";
			var speedUpBehaviour:SpeedUpBehaviour = new SpeedUpBehaviour();
			speedUpBehaviour.collectSound = _coffeeSound;
			speedUpBehaviour.particleEffect = _coffeeParticles;
			speedUpBehaviour.targetTransform = _heroSkin;
			powerup.children.addItem(speedUpBehaviour);
			
			// Update position values
			xpos += 60;
			
			// Add Mushroom powerup
			powerup = new Entity("Mushroom");
			powerupsEntity.children.addItem(powerup);
			imageSkin = new ImageSkin("Mushroom Skin");
			powerup.children.addItem(imageSkin);
			imageSkin.x = xpos;
			imageSkin.y = ypos;
			imageSkin.textureAtlas = _allSpritesAtlas;
			imageSkin.texturesPrefix = "item7";
			var magnetBehaviour:MagnetBehaviour = new MagnetBehaviour();
			powerup.children.addItem(magnetBehaviour);
			magnetBehaviour.collectSound = _mushroomSound;
			magnetBehaviour.particleEffect = _mushroomParticles;
			magnetBehaviour.targetTransform = _heroSkin;
			
			// Add ItemsProcess
			var itemsProcess:ItemsProcess = new ItemsProcess();
			_cadetScene.children.addItem(itemsProcess);
			itemsProcess.collectSound = _eatSound;
			itemsProcess.itemsContainer = itemsEntity;
			itemsProcess.powerupsContainer = powerupsEntity;
			itemsProcess.hitTestSkin = _heroSkin;
			// Add default MoveBehaviour to ItemsProcess
			var defaultMoveBehaviour:MoveBehaviour = new MoveBehaviour();
			itemsProcess.children.addItem(defaultMoveBehaviour);
			defaultMoveBehaviour.angle = 270;
		}
		
		private function addObstacles():void
		{
			// Place items to the right of the stage
			var startXpos:Number = _worldBounds.right + 20;
			var startYpos:Number = 120;
			
			var xpos:Number = startXpos;
			var ypos:Number = startYpos;
			
			var warningSkin:MovieClipSkin = new MovieClipSkin("Watch Out Skin");
			_cadetScene.children.addItem(warningSkin);
			warningSkin.textureAtlas = _allSpritesAtlas;
			warningSkin.texturesPrefix = "watchOut_";
			warningSkin.loop = true;
			warningSkin.x = xpos;
			warningSkin.y = ypos
				
			// Update position values
			ypos += 100;
			
			// Add the Obstacles Entity
			var obstaclesEntity:Entity = new Entity("Obstacles");
			_cadetScene.children.addItem(obstaclesEntity);
			
			for ( var i:uint = 0; i < 3; i ++ ) {
				var obstacle:Entity = new Entity("Obstacle "+(i+1));
				// Add the default ImageSkin to the obstacle entity
				var defaultSkin:ImageSkin = new ImageSkin("Default Skin");
				obstacle.children.addItem(defaultSkin);
				defaultSkin.textureAtlas = _allSpritesAtlas;
				defaultSkin.texturesPrefix = "obstacle"+(i+1);
				// Add the crash ImageSkin to the obstacle entity
				var crashSkin:ImageSkin = new ImageSkin("Crash Skin");
				obstacle.children.addItem(crashSkin);
				crashSkin.textureAtlas = _allSpritesAtlas;
				crashSkin.texturesPrefix = "obstacle"+(i+1)+"_crash";
				// Add the Transform2D to the obstacle entity
				var transform:Transform2D = new Transform2D();
				obstacle.children.addItem(transform);
				transform.x = xpos;
				transform.y = ypos;
				// Add the ObstacleBehaviour to the obstacle entity
				var behaviour:ObstacleBehaviour = new ObstacleBehaviour();
				obstacle.children.addItem(behaviour);
				behaviour.defaultSkin = defaultSkin;
				behaviour.crashSkin = crashSkin;
				behaviour.warningSkin = warningSkin;
				// Finally, add the obstacle entity to the container entity
				obstaclesEntity.children.addItem(obstacle);	
				
				ypos += 90;
			}
			
			// Helicopter Obstacle
			obstacle = new Entity("Obstacle 4");
			var defaultMcSkin:MovieClipSkin = new MovieClipSkin("Default Skin");
			obstacle.children.addItem(defaultMcSkin);
			defaultMcSkin.textureAtlas = _allSpritesAtlas;
			defaultMcSkin.texturesPrefix = "obstacle4_0";
			defaultMcSkin.loop = true;
			// Add the crash ImageSkin to the obstacle entity
			crashSkin = new ImageSkin("Crash Skin");
			obstacle.children.addItem(crashSkin);
			crashSkin.textureAtlas = _allSpritesAtlas;
			crashSkin.texturesPrefix = "obstacle4_crash";
			// Add the Transform2D to the obstacle entity
			transform = new Transform2D();
			obstacle.children.addItem(transform);
			transform.x = xpos;
			transform.y = ypos;
			// Add the ObstacleBehaviour to the obstacle entity
			behaviour = new ObstacleBehaviour();
			obstacle.children.addItem(behaviour);
			behaviour.defaultSkin = defaultMcSkin;
			behaviour.crashSkin = crashSkin;
			behaviour.warningSkin = warningSkin;
			// Finally, add the obstacle entity to the container entity
			obstaclesEntity.children.addItem(obstacle);
			
			var obstaclesProcess:ObstaclesProcess = new ObstaclesProcess();
			_cadetScene.children.addItem(obstaclesProcess);
			obstaclesProcess.obstaclesContainer = obstaclesEntity;
			obstaclesProcess.hitTestSkin = _heroSkin;
			obstaclesProcess.hitSound = _hitSound;
			obstaclesProcess.hurtSound = _hurtSound;
		}
		
		private function addParticles():void
		{
			// Place items to the right of the stage
			var startXpos:Number = _worldBounds.right + 20;
			var startYpos:Number = 600;
			
			var xpos:Number = startXpos;
			var ypos:Number = startYpos;
			
			var particleSkin:ImageSkin;
			var particlesEntity:Entity;
			
			// Add Eat particles Entity
			particlesEntity = new Entity("Eat Particles");
			_cadetScene.children.addItem(particlesEntity);
			
			// Add Eat particle Skin
			particleSkin = new ImageSkin("Eat Particles Skin");
			particlesEntity.children.addItem(particleSkin);
			particleSkin.textureAtlas = _allSpritesAtlas;
			particleSkin.texturesPrefix = "particleEat";
			particleSkin.x = xpos;
			particleSkin.y = ypos;
			
			// Add EatParticlesProcess
			var eatParticlesProcess:EatParticlesProcess = new EatParticlesProcess();
			_cadetScene.children.addItem(eatParticlesProcess);
			eatParticlesProcess.particlesContainer = particlesEntity;
			
			// Add Wind particles Entity
			particlesEntity = new Entity("Wind Particles");
			_cadetScene.children.addItem(particlesEntity);
			
			// Update positions
			xpos += 40;
			
			// Add Wind particle Skin
			particleSkin = new ImageSkin("Wind Particles Skin");
			particlesEntity.children.addItem(particleSkin);
			particleSkin.textureAtlas = _allSpritesAtlas;
			particleSkin.texturesPrefix = "particleWindForce";
			particleSkin.x = xpos;
			particleSkin.y = ypos;
			
			// Add WindParticlesProcess
			var windParticlesProcess:WindParticlesProcess = new WindParticlesProcess();
			_cadetScene.children.addItem(windParticlesProcess);
			windParticlesProcess.particlesContainer = particlesEntity;
			
			// Add Coffee ParticleSystemComponent
			_coffeeParticles = new PDParticleSystemComponent(null, null, "Coffee Particles");
			_resourceManager.bindResource(particleCoffeeXMLURL, _coffeeParticles, "xml");
			_coffeeParticles.autoplay = false;
			_cadetScene.children.addItem(_coffeeParticles);
			
			// Add Mushroom ParticleSystemComponent
			_mushroomParticles = new PDParticleSystemComponent(null, null, "Mushroom Particles");
			_resourceManager.bindResource(particleMushroomXMLURL, _mushroomParticles, "xml");
			_mushroomParticles.autoplay = false;
			_cadetScene.children.addItem(_mushroomParticles);
		}
	}
}
















