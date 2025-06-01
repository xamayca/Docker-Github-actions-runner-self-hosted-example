<?php

namespace App\Tests\Unit;

use App\Entity\Post;
use PHPUnit\Framework\Attributes\CoversClass;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

#[CoversClass(Post::class)]
class PostTest extends TestCase
{
    public function test_post_is_valid_with_proper_data(): void
    {
        $post = new Post(
            id: 1,
            title: "Titre d'article valide",
            content: "Contenu d'article valide",
        );

        self::assertSame(1, $post->id);
        self::assertSame("Titre d'article valide", $post->title);
        self::assertSame("Contenu d'article valide", $post->content);
    }

    /**
     * Fournit un ensemble de cas d'article invalide pour les tests unitaires de l'entité Post.
     *
     * Chaque cas de test retourne un tableau associatif contenant :
     *  - id : identifiant de l'article (int)
     *  - title : titre de l'article (string)
     *  - content : contenu de l'article (string)
     *  - exception : message d'exception attendu
     *
     * @return array<string, array{ id: int, title: string, content: string, exception: string }>
     * @see Post
     */
    public static function postDataProvider(): array
    {
        return [
            'title_empty' => [
                'id' => 1,
                'title' => "",
                'content' => "Contenu de l'article valide avec au moins dix caractères",
                'exception' => "Le titre ne peut pas être vide."
            ],
            'title_null' => [
                'id' => 1,
                'title' => "",
                'content' => "Contenu de l'article valide avec au moins dix caractères",
                'exception' => "Le titre ne peut pas être vide."
            ],
            'title_too_short' => [
                'id' => 1,
                'title' => "Titre",
                'content' => "Contenu de l'article valide avec au moins dix caractères",
                'exception' => "Le titre doit être compris entre 10 et 150 caractères."
            ],
            'title_too_long' => [
                'id' => 1,
                'title' => str_repeat("Titre d'article invalide supérieur a 150 caractères", 10),
                'content' => "Contenu de l'article valide avec au moins dix caractères",
                'exception' => "Le titre doit être compris entre 10 et 150 caractères."
            ],
            'content_empty' => [
                'id' => 1,
                'title' => "Titre d'article valide",
                'content' => "",
                'exception' => "Le contenu ne peut pas être vide."
            ],
            'content_too_short' => [

                'title' => "Titre d'article valide",
                'content' => "Contenu",
                'exception' => "Le contenu doit être compris entre 10 et 150 caractères."
            ],
            'content_too_long' => [
                'id' => 1,
                'title' => "Titre d'article valide",
                'content' => str_repeat("Contenu de l'article invalide supérieur a 150 caractères", 10),
                'exception' => "Le contenu doit être compris entre 10 et 150 caractères."
            ],
        ];
    }

    #[DataProvider('postDataProvider')]
    public function test_post_throw_exception(int $id, string $title, string $content, string $exception): void
    {
        self::expectException(\Exception::class);
        self::expectExceptionMessage($exception);

        $post = new Post(
            id: $id,
            title: $title,
            content: $content,
        );
    }

}